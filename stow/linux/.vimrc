" -----------------------------------------------------------------------------
" Author: Marcos Azevedo aka psylinux
" Email: psylinux@gmail.com
" Created: 2010-03-11
" Updated: 2025-11-21
" Description: VIMRC Configuration

" ----------------------------------------------------
" ================ Initial Config ====================
" ----------------------------------------------------

"""" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
set encoding=UTF-8

" Change leader to a comma because the backslash is too far away
" That means all \x commands turn into ,x
" The mapleader has to be set before vundle starts loading all
" the plugins.
let mapleader=","

" Enable Elite mode
let g:elite_mode=1


" ----------------------------------------------------
" ==================== Plugins =======================
" ----------------------------------------------------

"""" START Vundle Configuration

" Disable file type for vundle
filetype off                              "Required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

  """" Vundle to manage plugins
  Plugin 'gmarik/Vundle.vim'

  """" Utility
  Plugin 'tmux-plugins/vim-tmux'          "tmux plugin
  Plugin 'junegunn/goyo.vim'              "distraction free
  Plugin 'majutsushi/tagbar'
  Plugin 'ervandew/supertab'
  Plugin 'BufOnly.vim'
  Plugin 'wesQ3/vim-windowswap'
  Plugin 'SirVer/ultisnips'
  Plugin 'junegunn/fzf.vim'
  Plugin 'junegunn/fzf'
  Plugin 'ctrlpvim/ctrlp.vim'
  Plugin 'benmills/vimux'
  Plugin 'jeetsukumaran/vim-buffergator'
  Plugin 'gilsondev/searchtasks.vim'
  Plugin 'Shougo/neocomplete.vim'
  Plugin 'tpope/vim-dispatch'
  Plugin 'jceb/vim-orgmode'
  Plugin 'tpope/vim-speeddating'
  Plugin 'calorie/vim-typing-sound'

  " Generic Programming Support
  Plugin 'tpope/vim-endwise'
  Plugin 'universal-ctags/ctags'
  Plugin 'honza/vim-snippets'
  Plugin 'neomake/neomake'
  Plugin 'vim-syntastic/syntastic'
  Plugin 'ncm2/ncm2'                      "awesome autocomplete plugin
  Plugin 'ncm2/ncm2-bufword'              "buffer keyword completion
  Plugin 'ncm2/ncm2-path'                 "filepath completion
  Plugin 'HansPinckaers/ncm2-jedi'        "fast python completion (use ncm2 if you want type info or snippet support)
  Plugin 'Townk/vim-autoclose'
  Plugin 'tomtom/tcomment_vim'
  Plugin 'tobyS/vmustache'
  Plugin 'maksimr/vim-jsbeautify'
  Plugin 'davidhalter/jedi-vim'           "jedi for python
  Plugin 'Vimjas/vim-python-pep8-indent'  "better indenting for python
  Plugin 'dense-analysis/ale'             "python linters
  "Plugin 'janko-m/vim-test'

  " Markdown / Writting
  Plugin 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install' }
  "Plugin 'reedes/vim-pencil'
  Plugin 'tpope/vim-markdown'
  Plugin 'jtratner/vim-flavored-markdown'
  Plugin 'LanguageTool'
  Plugin 'junegunn/limelight.vim'         "dim other paragraphs
  Plugin 'godlygeek/tabular'              "aligning text with

  " Git Support
  Plugin 'kablamo/vim-git-log'
  Plugin 'gregsexton/gitv'
  Plugin 'tpope/vim-fugitive'
  Plugin 'tpope/vim-git'
  Plugin 'mattn/gist-vim'
  Plugin 'mattn/webapi-vim'
  Plugin 'airblade/vim-gitgutter'         "show git changes to files in gutter
  Plugin 'mhinz/vim-signify'              "show git file changes in the gutter
  "Plugin 'jaxbot/github-issues.vim'

  " Theme / Interface
  Plugin 'jonathanfilip/vim-lucius'       "nice white colortheme
  Plugin 'AnsiEsc.vim'
  Plugin 'ryanoasis/vim-devicons'
  Plugin 'vim-airline/vim-airline'
  Plugin 'vim-airline/vim-airline-themes'
  Plugin 'sjl/badwolf'
  Plugin 'tomasr/molokai'
  Plugin 'morhetz/gruvbox'
  Plugin 'zenorocha/dracula-theme', {'rtp': 'vim/'}
  Plugin 'mkarmona/colorsbox'
  Plugin 'romainl/Apprentice'
  Plugin 'Lokaltog/vim-distinguished'
  Plugin 'chriskempson/base16-vim'
  Plugin 'w0ng/vim-hybrid'
  Plugin 'AlessandroYorba/Sierra'
  Plugin 'daylerees/colour-schemes'
  Plugin 'effkay/argonaut.vim'
  " Plugin 'ajh17/Spacegray.vim'
  Plugin 'atelierbram/Base2Tone-vim'
  Plugin 'colepeters/spacemacs-theme.vim'
  Plugin 'dylanaraps/wal.vim'
  Plugin 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }

  """"NERDTree
  Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
  Plugin 'scrooloose/nerdtree'

  """" Neosnippet Plugins
  Plugin 'Shougo/deoplete.nvim'
  if !has('nvim')
    Plugin 'roxma/nvim-yarp'
    Plugin 'roxma/vim-hug-neovim-rpc'
  endif
  Plugin 'Shougo/neosnippet.vim'
  Plugin 'Shougo/neosnippet-snippets'

call vundle#end()               "required

filetype plugin on              "required
filetype indent on              "required

"""" END Vundle Configuration


" ----------------------------------------------------
" ================ General Config ====================
" ----------------------------------------------------
set showcmd                     "Show incomplete cmds down the bottom
set autoread                    "Reload files changed outside vim
set laststatus=2                "Always display the status line
set nowrap                      "Don't wrap lines
set number                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=10000               "Store lots of :cmdline history
set showmode                    "Show current mode down the bottom
set gcr=a:blinkon0              "Disable cursor blink
set visualbell                  "No sounds
set cursorline                  "Enable highlighting of the current line

"""" Turn off swap files
set noswapfile
set nobackup
set nowb

"""" Persistent Undo
" Checking if distribution has the 'persistent_undo' feature.
if has('persistent_undo')
    " define a path to store persistent undo files.
    let target_path = expand('~/.config/vim-persisted-undo/')    "create the directory and any parent directories
    " if the location does not exist.
    if !isdirectory(target_path)
        call system('mkdir -p ' . target_path)
    endif    " point Vim to the defined undo directory.
    let &undodir = target_path    " finally, enable undo persistence.
    set undofile
endif

"""" Set Proper Tabs
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab

"""" Configuring Color Scheme
let base16colorspace=256                        "Access colors present in 256 colorspace
if empty(globpath(&rtp, 'colors/challenger_deep.vim'))
    " Fallback if theme not installed yet (first run before PluginInstall).
    colorscheme desert
else
    let g:challenger_deep_termcolors=256
    colorscheme challenger_deep
endif

"""" Theme and Styling
syntax on
set t_Co=256
set list listchars=tab:\ \ ,trail:·             "Display tabs and trailing spaces visually
let g:spacegray_underline_search = 1
let g:spacegray_italicize_comments = 1

"""" Devicons configuration (must be the last one to load)
let g:webdevicons_enable=1                      "Loading the plugin
let g:webdevicons_enable_nerdtree=1             "Adding the flags to NERDTree
let g:webdevicons_conceal_nerdtree_brackets=1
let g:WebDevIconsNerdTreeAfterGlyphPadding=' '

" Vim-Airline Configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme='hybrid'
let g:hybrid_custom_term_colors = 1
let g:hybrid_reduced_contrast = 1

" Syntastic Configuration
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1

" Neomake settings
autocmd! BufWritePost * Neomake

"""" Neocomplete Settings
  let g:acp_enableAtStartup = 0
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
  let g:neocomplete#sources#syntax#min_keyword_length = 3

  " [Neocomplete] Define dictionary
  let g:neocomplete#sources#dictionary#dictionaries = {
      \ 'default' : '',
      \ 'vimshell' : $HOME.'/.vimshell_hist',
      \ 'scheme' : $HOME.'/.gosh_completions'
      \ }

  " [Neocomplete] Define keyword
  if !exists('g:neocomplete#keyword_patterns')
      let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns['default'] = '\h\w*'

  " [Neocomplete] Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? "\<C-y>" : "\<CR>"
  endfunction

  " [Neocomplete] Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

  " [Neocomplete] Enable heavy omni completion.
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif
  let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

  " [Neocomplete] For perlomni.vim setting.
  " https://github.com/c9s/perlomni.vim
  let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

"""" Markdown Syntax Support
augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

" Vim-Supertab Configuration
let g:SuperTabDefaultCompletionType = "<C-X><C-O>"

" Settings for Writting
let g:languagetool_jar = '/opt/languagetool/languagetool-commandline.jar'

" Vim-pencil Configuration
"let g:pencil#wrapModeDefault = 'soft'   " default is 'hard'
"augroup pencil
"  autocmd!
"  autocmd FileType markdown,mkd,md  call pencil#init()
"  autocmd FileType text             call pencil#init()
"augroup END

" Vim-UtilSnips Configuration
" Trigger configuration.
" Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"         "if you want :UltiSnipsEdit to split your window.

" Vim-Test Configuration
"let test#strategy = "vimux"

" Fzf Configuration
" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Default fzf layout
" down / up / left / right
let g:fzf_layout = { 'down': '~40%' }

" In Neovim, you can set up fzf window using a Vim command
let g:fzf_layout = { 'window': 'enew' }
let g:fzf_layout = { 'window': '-tabnew' }

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'

"""" Devicons configuration (must be the last one to load)
let g:webdevicons_enable=1                      "Loading the plugin
let g:webdevicons_enable_nerdtree=1             "Adding the flags to NERDTree
let g:webdevicons_conceal_nerdtree_brackets=1
let g:WebDevIconsNerdTreeAfterGlyphPadding=' '

"""" iamcco/markdown-preview.nvim
let g:mkdp_auto_close=0
let g:mkdp_refresh_slow=1
let g:mkdp_markdown_css='~/.local/share/github-markdown-css/github-markdown.css'


" ----------------------------------------------------
" ============ Mappings configurationn ===============
" ----------------------------------------------------
map <C-n> :NERDTreeToggle<CR>

"""" Ctags Configuration
nnoremap <leader>. :CtrlPTag<cr>
map <C-m> :TagbarToggle<CR>

" [Neocomplete] Omnicomplete Better Nav
inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")

" [Neocomplete] Plugin mappings
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" [Neocomplete] <TAB>: completion
inoremap <expr> <tab> pumvisible() ? "\<C-n>" : "\<tab>"

" [Neocomplete] <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"

" Mapping selecting Mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Shortcuts
nnoremap <Leader>o :Files<CR>
nnoremap <Leader>O :CtrlP<CR>
nnoremap <Leader>w :w<CR>

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

" Vim-Test Mappings
"nmap <silent> <leader>t :TestNearest<CR>
"nmap <silent> <leader>T :TestFile<CR>
"nmap <silent> <leader>a :TestSuite<CR>
"nmap <silent> <leader>l :TestLast<CR>
"nmap <silent> <leader>g :TestVisit<CR>

" Disable arrow movement, resize splits instead.
if get(g:, 'elite_mode')
	nnoremap <Up>    :resize -2<CR>
	nnoremap <Down>  :resize +2<CR>
	nnoremap <Left>  :vertical resize -2<CR>
	nnoremap <Right> :vertical resize +2<CR>
endif

map <silent> <LocalLeader>ws :highlight clear ExtraWhitespace<CR>

" Advanced customization using autoload functions
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '12%'})

" Tabularize
nmap <leader>a= :Tabularize /=<CR>
vmap <leader>a= :Tabularize /=<CR>
nmap <leader>a: :Tabularize /:\zs<CR>
vmap <leader>a: :Tabularize /:\zs<CR>

" Edit vimr configuration file
nnoremap <Leader>ve :e $MYVIMRC<CR>
" Reload vimr configuration file
nnoremap <Leader>vr :source $MYVIMRC<CR>
