#!/bin/bash

# Setup Ubuntu Development Environment

## retrieve new lists of packages
sudo apt-get update -y

## clone dotfiles
git clone https://github.com/storyn26383/dotfiles.git ~/dotfiles -b ubuntu

## install docker
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

## install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

## install phpbrew
sudo apt-get install -y build-essential libbz2-dev libreadline-dev libsqlite3-dev libssl-dev libxml2-dev libxslt-dev php7.4-cli php7.4-bz2 pkg-config
curl -L -O https://github.com/phpbrew/phpbrew/releases/latest/download/phpbrew.phar
chmod +x phpbrew.phar
sudo mv phpbrew.phar /usr/local/bin/phpbrew
phpbrew init

## install composer
curl -sS https://getcomposer.org/installer | php
chmod +x composer.phar
sudo mv composer.phar /usr/local/bin/composer

## install tig
INSTALL_PATH=/tmp/tig
sudo apt-get install -y build-essential make libncursesw5-dev asciidoc
git clone https://github.com/jonas/tig.git $INSTALL_PATH
cd $INSTALL_PATH
make configure
./configure --with-ncursesw
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
sudo apt-get update -y
sudo apt-get install -y vim
git clone https://github.com/storyn26383/sasaya-vim.git ~/.vim
ln -s ~/.vim/.vimrc ~/.vimrc
vim +PlugInstall +qall

## powerline
sudo apt-get install -y python3-pip
sudo pip3 install powerline-status
sudo ln -s ~/dotfiles/powerline/themes/tmux/sasaya.json /usr/local/lib/python3.8/dist-packages/powerline/config_files/themes/tmux/sasaya.json
sudo ln -s ~/dotfiles/powerline/themes/shell/sasaya.json /usr/local/lib/python3.8/dist-packages/powerline/config_files/themes/shell/sasaya.json
sudo ln -s ~/dotfiles/powerline/colorschemes/sasaya.json /usr/local/lib/python3.8/dist-packages/powerline/config_files/colorschemes/sasaya.json
sudo ln -s ~/dotfiles/powerline/colorschemes/tmux/sasaya.json /usr/local/lib/python3.8/dist-packages/powerline/config_files/colorschemes/tmux/sasaya.json
sudo sed -i '21s/default/sasaya/' /usr/local/lib/python3.8/dist-packages/powerline/config_files/config.json
sudo sed -i '28,29s/default/sasaya/' /usr/local/lib/python3.8/dist-packages/powerline/config_files/config.json

## install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update -y
sudo apt-get install -y yarn

## install mosh
sudo apt-get install -y mosh

## install htop
sudo apt-get install -y htop

## install oh-my-zsh
INSTALLER=/tmp/oh-my-zsh-install.sh
sudo apt-get install -y zsh
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh > $INSTALLER
chmod +x $INSTALLER
sh $INSTALLER --skip-chsh --unattended
rm $INSTALLER
git clone https://github.com/chriskempson/base16-shell.git ~/.oh-my-zsh/custom/plugins/base16-shell

## install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash

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
