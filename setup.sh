#!/bin/bash

# Setup Ubuntu Development Environment

## clone dotfiles
git clone https://github.com/storyn26383/dotfiles.git ~/dotfiles -b ubuntu

## install php 7.2
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php7.2-cli

## install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"

## install tig
INSTALL_PATH=/tmp/tig
sudo apt-get install -y build-essential make libncurses5-dev asciidoc
git clone https://github.com/jonas/tig.git $INSTALL_PATH
cd $INSTALL_PATH
make prefix=/usr/local
sudo make install prefix=/usr/local
sudo make install-doc prefix=/usr/local
cd -
rm -rf $INSTALL_PATH

## install ctags
INSTALL_PATH=/tmp/ctags
sudo apt-get install -y autoconf pkg-config
git clone https://github.com/universal-ctags/ctags.git $INSTALL_PATH
cd $INSTALL_PATH
./autogen.sh
./configure
make
sudo make install
cd -
rm -rf $INSTALL_PATH

## install ag
sudo apt-get install -y silversearcher-ag

## install vim
sudo add-apt-repository -y ppa:jonathonf/vim
sudo apt-get update
sudo apt-get install -y vim
git clone https://github.com/storyn26383/sasaya-vim.git ~/.vim
ln -s ~/.vim/.vimrc ~/.vimrc
vim +PlugInstall +qall

## powerline
sudo apt-get install -y python-pip
sudo pip install powerline-status
sudo ln -s ~/dotfiles/powerline/themes/tmux/sasaya.json /usr/local/lib/python2.7/dist-packages/powerline/config_files/themes/tmux/sasaya.json
sudo ln -s ~/dotfiles/powerline/themes/shell/sasaya.json /usr/local/lib/python2.7/dist-packages/powerline/config_files/themes/shell/sasaya.json
sudo ln -s ~/dotfiles/powerline/colorschemes/sasaya.json /usr/local/lib/python2.7/dist-packages/powerline/config_files/colorschemes/sasaya.json
sudo ln -s ~/dotfiles/powerline/colorschemes/tmux/sasaya.json /usr/local/lib/python2.7/dist-packages/powerline/config_files/colorschemes/tmux/sasaya.json
sudo sed -i '21s/default/sasaya/' /usr/local/lib/python2.7/dist-packages/powerline/config_files/config.json
sudo sed -i '28,29s/default/sasaya/' /usr/local/lib/python2.7/dist-packages/powerline/config_files/config.json

## install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get install -y yarn

## install mosh
sudo apt-get install -y mosh

## install htop
sudo apt-get install -y htop

## install oh-my-zsh
INSTALLER=/tmp/oh-my-zsh-install.sh
sudo apt-get install -y zsh
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh > $INSTALLER
sudo sed -i 's/env zsh/#env zsh/' $INSTALLER
sudo sed -i 's/chsh -s/#chsh -s/' $INSTALLER
chmod +x $INSTALLER
sh -c $INSTALLER
rm $INSTALLER

## install nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

## install rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable

## link dotfiles
rm ~/.zshrc
ln -s ~/dotfiles/.zshrc ~
ln -s ~/dotfiles/.tigrc ~
ln -s ~/dotfiles/.tmux.conf ~
ln -s ~/dotfiles/.gitconfig ~
ln -s ~/dotfiles/.gitignore_global ~

## done
chsh -s $(grep /zsh$ /etc/shells | tail -1)
echo 'DONE!'
env zsh
