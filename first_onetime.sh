#!/bin/sh
#
# 手動でやること
# vmのstorage拡張 8G -> 32G with resize.bat
# http://qiita.com/takara@github/items/77182fe9d83142be5c5e
# resize2fsのとこだけxfsなのでxfs_growfs使う
# gitのinstallとssh-keygenしてgithub登録

cd $HOME
sudo yum -y update

sudo yum -y install epel-release
rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
sudo yum -y install the_silver_searcher
cd /etc/yum.repos.d
touch ./mongodb.repo
sudo tee mongodb.repo <<EOF
[mongodb]
name=MongoDB Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
gpgcheck=0
enabled=1
EOF
cd $HOME
sudo yum -y install mlocate zsh tmux openssl-devel readline-devel zlib-devel sqlite-devel lsof mongodb-org tig nodejs npm
sudo systemctl start mongod.service
sudo /sbin/chkconfig mongod on
sudo npm install -g jsfmt
sudo npm install -g sails
sudo npm install -g node-dev
sudo npm install -g pm2
sudo setenforce 0
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo mkdir /data
sudo mkdir /data/db
sudo chmod 777 /data/db
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
sudo rbenv install 2.3.1
sudo rbenv global 2.3.1
sudo rbenv rehash
curl -L -O https://github.com/peco/peco/releases/download/v0.2.0/peco_linux_amd64.tar.gz
tar -zxvf peco_linux_amd64.tar.gz
sudo mv peco_linux_amd64/peco /usr/local/bin
rm -rf peco_linux_amd64*
mkdir $HOME/work
sudo rbenv exec gem install bundler
sudo rbenv exec gem install sqlite3
source $HOME/.zprofile
sudo yum -y remove postgresql-server postgresql-contrib postgresql-devel postgresql-libs.x86_64 postgresql-libs.x86_64
sudo rm -rf /usr/lib64/pgsql /var/lib/pgsql && sudo userdel postgres
sudo yum -y install postgresql-server postgresql-contrib postgresql-devel
sudo mkdir -p /var/lib/pgsql/data
sudo chown postgres:postgres /var/lib/pgsql/data
sudo -u postgres initdb  -D '/var/lib/pgsql/data'
sudo systemctl start postgresql.service
sudo systemctl enable postgresql.service
sudo timedatectl set-timezone Asia/Tokyo
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
echo '***********************************'
echo 'aws configureを手動で実行して下さい'
echo '***********************************'
