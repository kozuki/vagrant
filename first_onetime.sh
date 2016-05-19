#!/bin/sh
#
# 手動でやること
# vmのstorage拡張 8G -> 32G with resize.bat
# http://qiita.com/takara@github/items/77182fe9d83142be5c5e
# resize2fsのとこだけxfsなのでxfs_growfs使う
# gitのinstallとssh-keygenしてgithub登録

cd $HOME
sudo yum -y update
sudo yum -y install mlocate zsh tmux openssl-devel readline-devel zlib-devel sqlite-devel postgresql-server postgresql-contrib postgresql-devel lsof
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
if sudo grep "^Defaults\s\+!secure_path$" /etc/sudoers
then
    echo ''
else
    sudo bash -c 'echo "Defaults !secure_path" | (EDITOR="tee -a" visudo)'
fi
if sudo grep "^Defaults\s\+env_keep\s\++=\s\+\"PATH RBENV_ROOT\"$" /etc/sudoers
then
    echo ''
else
    sudo bash -c 'echo "Defaults env_keep += \"PATH RBENV_ROOT\"" | (EDITOR="tee -a" visudo)'
fi
export RBENV_ROOT=/usr/local/rbenv
export PATH=${RBENV_ROOT}/bin:${PATH}
sudo git clone git://github.com/sstephenson/rbenv.git ${RBENV_ROOT}
sudo git clone git://github.com/sstephenson/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build
sudo rbenv init -
if grep "^export\s\+RBENV_ROOT="/usr/local/rbenv"$" $HOME/.zprofile
then
    echo ''
else
  zsh -c 'cat <<\__EOT__ >> $HOME/.zprofile
export RBENV_ROOT=/usr/local/rbenv
export PATH=$RBENV_ROOT/bin:$PATH
eval "$(rbenv init -)"
__EOT__'
fi
sudo rbenv install 2.2.3
sudo rbenv global 2.2.3
sudo rbenv rehash
curl -L -O https://github.com/peco/peco/releases/download/v0.2.0/peco_linux_amd64.tar.gz
tar -zxvf peco_linux_amd64.tar.gz
sudo mv peco_linux_amd64/peco /usr/local/bin
rm -rf peco_linux_amd64*
mkdir $HOME/work
sudo rbenv exec gem install bundler
sudo rbenv exec gem install sqlite3
source $HOME/.zprofile
sudo postgresql-setup initdb
#sudo sed -e 's/peer$/md5/g' /var/lib/pgsql/data/pg_hba.conf | sudo tee /var/lib/pgsql/data/pg_hba.conf
#sudo sed -e 's/ident$/md5/g' /var/lib/pgsql/data/pg_hba.conf | sudo tee /var/lib/pgsql/data/pg_hba.conf
touch temp.conf
sudo sed -e 's/\(peer\|ident\)$/md5/g' /var/lib/pgsql/data/pg_hba.conf > temp.conf
sudo mv temp.conf /var/lib/pgsql/data/pg_hba.conf
echo 'postgres' | sudo passwd --stdin postgres
sudo systemctl start postgresql
sudo systemctl enable postgresql
