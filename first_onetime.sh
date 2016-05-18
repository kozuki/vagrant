#!/bin/sh

# gitのinstallとssh-keygenしてgithub登録は手動

sudo yum -y update
sudo yum -y install mlocate zsh tmux
sudo updatedb
git clone git@github.com:ikneg/dotfiles.git
cd $HOME/dotfiles
git pull
cd $HOME
mkdir $HOME/.vimbackup
rm $HOME/.vim
ln -s dotfiles/.vim $HOME/.vim
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
rm $HOME/.vimrc
cat << EOF >> .vimrc
set runtimepath+=~/.vim/bundle/neobundle.vim
call neobundle#begin(expand('~/.vim/bundle'))
NeoBundle 'altercation/vim-colors-solarized'
EOF
vim +":NeoBundleInstall" +:q
git clone git@github.com:seebi/dircolors-solarized.git $HOME/.dircolors-solarized
rm $HOME/.vimrc
ln -s dotfiles/.vimrc $HOME/.vimrc
rm $HOME/.zprofile
ln -s dotfiles/.zprofile $HOME/.zprofile
rm $HOME/.zshrc
ln -s dotfiles/.zshrc $HOME/.zshrc
rm $HOME/.tmux.conf
ln -s dotfiles/.tmux.conf $HOME/.tmux.conf
rm $HOME/.gitignore
ln -s dotfiles/.gitignore $HOME/.gitignore
rm $HOME/.gitconfig
ln -s dotfiles/.gitconfig $HOME/.gitconfig
vim -N -u NONE -i NONE -V1 -e -s --cmd "source ~/.vimrc" --cmd NeoBundleInstall! --cmd qall!
sudo usermod -s /bin/zsh root
sudo usermod -s /bin/zsh $USER
sudo visudo -f /etc/sudoers.d/00_base
source .tmux.conf
#source .zprofile
#source .zshrc
curl -L -O https://github.com/peco/peco/releases/download/v0.2.0/peco_linux_amd64.tar.gz
tar -zxvf peco_linux_amd64.tar.gz
sudo mv peco_linux_amd64/peco /usr/local/bin
rm -rf peco_linux_amd64*
