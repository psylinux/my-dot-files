#!/bin/bash
#
# Copyright 2020 Marcos Azevedo (aka pylinux) : psylinux[at]gmail.com
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
echo "-------------------------------"
echo " Installing Dependencies:      "
echo "-------------------------------"
apt-get install lsb-base -y

echo "-------------------------------"
echo " Updating ZSH plugins: "
echo "-------------------------------"
omz update
asdf update

echo "-------------------------------"
echo " Current Version Info Follows: "
echo "-------------------------------"
lsb_release -i
lsb_release -r
lsb_release -d
lsb_release -c
printf "Kernel Version: ";uname -r
printf "Processor Type: ";uname -m
echo "------------------------------"
echo "     Performing updates:      "
echo "------------------------------"
echo "----- UPDATE -----"
apt-get update
echo "----- FULL-DIST-UPGRADE -----"
apt-get full-upgrade -y
apt-get dist-upgrade -y
echo "----- AUTOREMOVE -----"
apt-get autoremove -y
echo "----- CLEAN -----"
apt-get clean
echo "---- REMOVING OLD KERNELS ----"
./remove-old-kernel.sh
echo "------------------------------"
echo " Device Version Info Follows: "
echo "------------------------------"
lsb_release -i
lsb_release -r
lsb_release -d
lsb_release -c
printf "Kernel Version: ";uname -r
printf "Processor Type: ";uname -m
echo "------------------------------"
echo "System Updated - $(date +%d-%m-%Y-%H:%M)" >> /root/update.log


