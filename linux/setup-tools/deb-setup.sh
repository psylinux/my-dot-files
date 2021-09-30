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

echo -e "========================"
echo -e "[+] Preparing to install"
echo -e "========================"
sudo apt-get update
sudo apt-get autoremove -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y apt-transport-https

echo -e "============================="
echo -e "[+] Setting files and folders"
echo -e "============================="
sudo cp vimrc ~/.vim/
sudo cp .gitignore .gitmodules .gitconfig .tmux.conf .bashrc ~/
sudo cp -R .irssi ~/
sudo ln -sf ~/.vim/vimrc ~/.vimrc

echo -e "========================"
echo -e "[+] Restarting Shell Env"
echo -e "========================"
source ~/.bashrc

echo -e "=================="
echo -e "[+] Installing Git"
echo -e "=================="
sudo apt-get install -y git git-core

echo -e "========================"
echo -e "[+] Installing Compilers"
echo -e "========================"
sudo apt-get install -y cmake build-essential mingw-w64-x86-64-dev \
mingw-w64-tools mingw-w64-i686-dev mingw-w64-common mingw-w64 \
libclang-7-dev libclang-common-7-dev libclang1

echo -e "======================"
echo -e "[+] Installling Python"
echo -e "======================"
sudo apt-get install -y python-dev python-setuptools \
python-pip libgpgme-dev python-gtk2-dev python-wxtools idle
pip2 install --upgrade pip
pip2 install pygpgme gpg 

echo -e "===================="
echo -e "[+] Installing PyEnv"
echo -e "===================="
sudo apt-get install -y libedit-dev make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
curl https://pyenv.run | bash
pyenv install 3.7.4
pyenv global 3.7.4
pyenv local 3.7.4
pip3 install --upgrade pip

echo -e "==========================="
echo -e "[+] Installling Useful Apps"
echo -e "==========================="
sudo apt-get install -y chromium tmux keepnote lynx links mutt

echo -e "==============================="
echo -e "[+] Installling IRSSI and Tools"
echo -e "==============================="
sudo apt-get install -y irssi bitlbee bitlbee-plugin-otr \
libtime-duration-perl libnotify-bin irssi-plugin-otr

echo -e "=========================="
echo -e "[+] Installing GEF for GDB"
echo -e "=========================="
git clone https://github.com/hugsy/gef.git /opt/gef/
pip3 install keystone-engine unicorn ropper capstone
/opt/gef/scripts/gef.sh
/opt/gef/scripts/gef-extras.sh

echo -e "========================="
echo -e "[+] Installling VIM Tools"
echo -e "========================="
sudo apt-get install -y vim-python-jedi

echo -e "==========================="
echo -e "[+] Installing Sublime Text"
echo -e "==========================="
sudo wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install -y sublime-text

echo -e "======================="
echo -e "[+] Installing WikidPad"
echo -e "======================="
sudo apt-get install -y libpango1.0-0 libpangox-1.0-0
sudo cp WikidPad.sh /usr/bin
sudo cp -Ra .WikidPad* ~/
sudo mkdir ~/Apps
sudo cp -Ra WikidPad/ ~/Apps/

echo -e "================"
echo -e "[+] Seting up..."
echo -e "================"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo -e "==============================="
echo -e "[+] Installing VIM Dependencies"
echo -e "==============================="
sudo apt-get install -y libncurses5-dev lib32ncurses5-dev libncurses5*

# Installing Plugins
vim +PluginInstall +qall
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer

