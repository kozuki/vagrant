#!/bin/sh
#
# 手動でやること
# vmのstorage拡張 8G -> 32G with resize.bat
# http://qiita.com/takara@github/items/77182fe9d83142be5c5e
# resize2fsのとこだけxfsなのでxfs_growfs使う
# gitのinstallとssh-keygenしてgithub登録

cd $HOME
sudo yum -y update
sudo curl http://repo.mongodb.org/yum/redhat/mongodb-org.repo -o /etc/yum.repos.d/mongodb.repo
sudo yum -y install mlocate zsh tmux openssl-devel readline-devel zlib-devel sqlite-devel lsof mongodb-org
sudo setenforce 0
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl start mongod.service
sudo systemctl enable mongod.service
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
sudo yum -y remove postgresql-server postgresql-contrib postgresql-devel
sudo rm -rf /usr/lib64/pgsql /var/lib/pgsql && sudo userdel postgres
sudo yum -y install postgresql-server postgresql-contrib postgresql-devel
sudo postgresql-setup initdb
touch temp1.conf
touch temp2.conf
sudo sed -e 's/\peer$/trust/g' /var/lib/pgsql/data/pg_hba.conf > temp1.conf
sudo sed -e 's/\ident$/md5/g' temp1.conf > temp2.conf
sudo mv temp2.conf /var/lib/pgsql/data/pg_hba.conf
rm temp1.conf
sudo systemctl start postgresql
sudo systemctl enable postgresql
# TODO
# https://www.digitalocean.com/community/tutorials/how-to-use-postgresql-with-your-ruby-on-rails-application-on-centos-7
# railsで使うならpostgres権限でpg_hda.confのpeer修正
