#!/usr/bin/env bash
# aws-connect.sh - log in to an AWS CLI profile (only if needed) and make it the active one.
#
#   awsc <profile> [-f] [-r]               alias for "source aws-connect.sh" (zsh and bash rc files)
#   source aws-connect.sh <profile> [-f]   sets AWS_PROFILE in the current shell
#   aws-connect.sh <profile> [-f]          opens a new shell with AWS_PROFILE set (exit to go back)
#   aws-connect.sh                         usage + list of profiles
#
# The login step is chosen from the profile config:
#   sso_session / sso_start_url        -> aws sso login
#   aws_access_key_id (static keys)    -> no login, keys are used as they are
#   role_arn / credential_process      -> no login, the CLI gets credentials itself
#   anything else (login_session, or a new empty profile) -> aws login
# If the profile already has working credentials the login is skipped; -f forces it.
# Over SSH, or on Linux without a display, the login runs in remote mode (aws login --remote,
# aws sso login --use-device-code): open the printed URL on any device. -r forces remote mode.
#
# Needs AWS CLI v2 (aws login needs 2.32 or later). Works when sourced from zsh or bash, and when
# executed with bash 3.2+ (macOS /bin/bash). There is no "set -euo pipefail" on purpose: the file
# is meant to be sourced, and those options would leak into (and could close) the calling shell.

__aws_connect_usage() {
  cat <<'EOF'
Usage: awsc <profile> [-f] [-r]
       source aws-connect.sh <profile> [-f] [-r]
       aws-connect.sh <profile> [-f] [-r]

Logs in to an AWS CLI profile if its credentials do not work, shows the
caller identity and the profile region, and sets AWS_PROFILE and AWS_PAGER="".

  -f, --force   log in even if the current credentials still work
  -r, --remote  log in without a local browser: open the printed URL on any
                device (default over SSH, or on Linux without a display)
  -h, --help    show this help

Sourced (awsc), it changes the current shell. Executed, it cannot change the
shell that started it, so it opens a new shell with the profile set (type exit
to go back).
EOF
}

__aws_connect_main() {
  local profile="" force=0 remote=0 arg identity method method_desc region overrides depth

  for arg in "$@"; do
    case "$arg" in
      -f|--force) force=1 ;;
      -r|--remote) remote=1 ;;
      -h|--help) __aws_connect_usage; return 0 ;;
      -*)
        printf 'aws-connect: unknown option: %s\n\n' "$arg" >&2
        __aws_connect_usage >&2
        return 2 ;;
      *)
        if [ -n "$profile" ]; then
          printf 'aws-connect: give only one profile (got "%s" and "%s")\n' "$profile" "$arg" >&2
          return 2
        fi
        profile=$arg ;;
    esac
  done

  if ! command -v aws >/dev/null 2>&1; then
    printf 'aws-connect: aws CLI not found in PATH (install AWS CLI v2)\n' >&2
    return 127
  fi

  if [ -z "$profile" ]; then
    __aws_connect_usage >&2
    printf '\nProfiles:\n' >&2
    aws configure list-profiles | sed 's/^/  /' >&2
    return 2
  fi

  if ! aws configure list-profiles 2>/dev/null | grep -Fqx -- "$profile"; then
    printf 'aws-connect: profile "%s" not found. Profiles:\n' "$profile" >&2
    aws configure list-profiles | sed 's/^/  /' >&2
    return 1
  fi

  # Step 1: reuse working credentials. For an "aws login" profile this call also
  # refreshes an expired 12 h session silently, as long as the 90-day refresh is valid.
  if [ "$force" = 0 ] && identity=$(aws sts get-caller-identity --profile "$profile" \
      --no-cli-pager --cli-connect-timeout 5 --cli-read-timeout 15 2>&1); then
    printf '[%s] credentials are valid, login skipped (use -f to force it)\n' "$profile"
  else
    # Step 2: pick the login method from the profile config.
    if [ -n "$(aws configure get sso_session --profile "$profile" 2>/dev/null)" ] ||
       [ -n "$(aws configure get sso_start_url --profile "$profile" 2>/dev/null)" ]; then
      method=sso
    elif [ -n "$(aws configure get aws_access_key_id --profile "$profile" 2>/dev/null)" ]; then
      method=none; method_desc="static access keys"
    elif [ -n "$(aws configure get role_arn --profile "$profile" 2>/dev/null)" ] ||
         [ -n "$(aws configure get credential_process --profile "$profile" 2>/dev/null)" ]; then
      method=none; method_desc="role_arn or credential_process"
    else
      method=login
    fi

    # No usable local browser: SSH session, or Linux without X11/Wayland.
    if [ "$remote" = 0 ]; then
      if [ -n "${SSH_CONNECTION:-}" ] ||
         { [ "$(uname -s)" != Darwin ] && [ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; }; then
        remote=1
      fi
    fi

    case "$method" in
      sso)
        if [ "$remote" = 1 ]; then
          printf '[%s] logging in (remote mode, open the URL on any device): aws sso login --use-device-code --no-browser --profile %s\n' \
            "$profile" "$profile"
          aws sso login --use-device-code --no-browser --profile "$profile" || return 1
        else
          printf '[%s] logging in: aws sso login --profile %s\n' "$profile" "$profile"
          aws sso login --profile "$profile" || return 1
        fi ;;
      login)
        if [ "$remote" = 1 ]; then
          printf '[%s] logging in (remote mode, open the URL on any device and paste the code back): aws login --remote --profile %s\n' \
            "$profile" "$profile"
          aws login --remote --profile "$profile" || return 1
        else
          printf '[%s] logging in: aws login --profile %s\n' "$profile" "$profile"
          aws login --profile "$profile" || return 1
        fi ;;
      none)
        if [ "$force" = 0 ]; then
          printf 'aws-connect: profile "%s" uses %s, which have no login step, and they failed:\n%s\n' \
            "$profile" "$method_desc" "$identity" >&2
          return 1
        fi
        printf '[%s] uses %s, no login step\n' "$profile" "$method_desc" ;;
    esac

    if ! identity=$(aws sts get-caller-identity --profile "$profile" --no-cli-pager 2>&1); then
      printf 'aws-connect: still no valid credentials for "%s":\n%s\n' "$profile" "$identity" >&2
      return 1
    fi
  fi

  region=$(aws configure get region --profile "$profile" 2>/dev/null)
  printf '%s\n' "$identity"
  if [ -n "$region" ]; then
    printf 'Region: %s\n' "$region"
  else
    printf 'Region: not set (set it with: aws configure set region <region> --profile %s)\n' "$profile"
  fi

  # Environment variables that silently beat AWS_PROFILE or the profile region.
  overrides=""
  [ -n "${AWS_ACCESS_KEY_ID:-}" ] && overrides="$overrides AWS_ACCESS_KEY_ID"
  [ -n "${AWS_SECRET_ACCESS_KEY:-}" ] && overrides="$overrides AWS_SECRET_ACCESS_KEY"
  [ -n "${AWS_SESSION_TOKEN:-}" ] && overrides="$overrides AWS_SESSION_TOKEN"
  [ -n "${AWS_REGION:-}" ] && overrides="$overrides AWS_REGION"
  [ -n "${AWS_DEFAULT_REGION:-}" ] && overrides="$overrides AWS_DEFAULT_REGION"
  if [ -n "$overrides" ]; then
    printf 'aws-connect: warning: these variables override the profile for commands without --profile:%s\n' \
      "$overrides" >&2
    printf '             clear them with: unset%s\n' "$overrides" >&2
  fi

  export AWS_PROFILE="$profile" AWS_PAGER=""

  if [ "$__aws_connect_sourced" = 1 ]; then
    printf 'AWS_PROFILE=%s set in this shell.\n' "$profile"
    return 0
  fi

  if [ -t 0 ] && [ -t 1 ]; then
    depth=$(( ${AWS_CONNECT_DEPTH:-0} + 1 ))
    export AWS_CONNECT_DEPTH="$depth"
    printf 'Opening a new shell with AWS_PROFILE=%s (nested level %s, type exit to go back).\n' "$profile" "$depth"
    printf 'Tip: "awsc %s" (or "source aws-connect.sh %s") sets it in the current shell without nesting.\n' \
      "$profile" "$profile"
    exec "${SHELL:-/bin/zsh}" -i
  fi

  printf 'aws-connect: not running in a terminal, so no shell was opened. Use:\n  export AWS_PROFILE=%s AWS_PAGER=""\n' \
    "$profile" >&2
  return 0
}

# Sourced or executed? Sourced code must use "return", never "exit" (exit would close your shell).
__aws_connect_sourced=0
if [ -n "${ZSH_VERSION:-}" ]; then
  case "${ZSH_EVAL_CONTEXT:-}" in *:file*) __aws_connect_sourced=1 ;; esac
elif [ -n "${BASH_VERSION:-}" ]; then
  [ "${BASH_SOURCE[0]}" != "$0" ] && __aws_connect_sourced=1
fi

if [ "$__aws_connect_sourced" = 1 ]; then
  __aws_connect_main "$@"
  # $? is expanded before eval runs, so the helpers are removed and the status is kept.
  eval "unset -f __aws_connect_main __aws_connect_usage; unset __aws_connect_sourced; return $?"
else
  __aws_connect_main "$@"
  exit $?
fi
