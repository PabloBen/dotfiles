#!/usr/bin/env bash

cd ~/Downloads || exit

# Installs rustup compiler
sudo apt install curl
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Clones alacritty repository
git clone https://github.com/alacritty/alacritty.git
cd alacritty || exit

# Installs dependencies
sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

# Compiles the release for alacritty
cargo build --release

# The following lines will add Alacritty to the Ubuntu start menu
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

# The following lines will add Alacritty documentation to Ubuntu man pages
sudo mkdir -p /usr/local/share/man/man1
gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null

# The following lines will add a new bash_completion/alacritty file for the automatic completions with Alacritty
mkdir -p ~/.bash_completion
cp extra/completions/alacritty.bash ~/.bash_completion/alacritty
echo "source ~/.bash_completion/alacritty" >> ~/.bashrc

# The following lines will add Alacritty as default terminal emulator whenever a new terminal is launched
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/alacritty 1
sudo update-alternatives --set x-terminal-emulator /usr/local/bin/alacritty

# These lines will download the default alacritty themes
mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes