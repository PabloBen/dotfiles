#!/usr/bin/env bash

sudo apt install -y wget
cd ~/Downloads || exit
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Mononoki.zip
unzip Mononoki.zip

mkdir ~/.fonts
mv Mononoki* ~/.fonts