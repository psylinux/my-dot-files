#!/bin/bash

echo "Current Kernel"
lsb_release -a

echo "Getting old Kernels"
dpkg --list | grep -i -E --color 'linux-image|linux-kernel' | grep '^ii'

echo "Currently running Linux kernel [NOT DELETE]"
v="$(uname -r | awk -F '-virtual' '{ print $1}')"
echo "$v"
i="linux-headers-virtual|linux-image-virtual|linux-headers-generic-hwe-|linux-image-generic-hwe-|linux-headers-${v}|linux-image-$(uname -r)|linux-image-generic|linux-headers-generic"
echo "$i"

echo "Going to DELETE this"
dpkg --list | egrep -i 'linux-image|linux-headers' | awk '/ii/{ print $2}' | egrep -v "$i"
apt-get --purge remove $(dpkg --list | egrep -i 'linux-image|linux-headers' | awk '/ii/{ print $2}' | egrep -v "$i")
