#!/bin/bash

#!/bin/bash


# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Ask for the username
read -p "Enter the username you wish to add: " USERNAME

# Add the new user (you might want to add additional options as needed)
adduser $USERNAME

# Add user to the wheel group for sudo privileges
addgroup $USERNAME wheel

# Update apk and upgrade existing packages
apk update && apk upgrade

# Install core utilities and sudo

apk add bash coreutils sudo shadow vim curl wget git openssh openssh-askpass openssh-client-common aconf-mod-openssh acf-openssh openssh-client-default openssh-dbg
apk add openssh-doc openssh-keygen openssh-keysign openssh-server openssh-server-commmon openssh-server-common-openrc openssh-server-krb5 openssh-server-pam
apk add openssh-sftp-server openssh-sk-helper perl-net-openssh perl-net-openssh-doc lxqt-openssh-askpass lxqt-openssh-askpass-doc lxqt-openssh-askpass-lang



# Setup a non-root user (replace 'myuser' with your desired username)

echo '$USERNAME ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME


# Setup locale (Alpine uses musl-locales)
apk add musl-locales musl-locales-lang
echo 'export LANG=en_DK.UTF-8' >> /etc/profile
echo 'export LANGUAGE=en_DK.UTF-8' >> /etc/profile
echo 'export LC_ALL=C.UTF-8' >> /etc/profile
source /etc/profile

# Optional: Install additional packages as needed
# apk add <package_name>

apk add linux-headers make perl-utils perl-error sudo

# Install sudo and setup sudoers
echo "Setting up sudo..."
apk add sudo
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel
chmod 0440 /etc/sudoers.d/wheel



apk add bash-completion

apk add zsh-completion


cat /etc/bash/bash_completion.sh

apk add sudo
NEWUSER='hwj'
adduser -g "${NEWUSER}" $NEWUSER
echo "$NEWUSER ALL=(ALL) ALL" > /etc/sudoers.d/$NEWUSER && chmod 0440 /etc/sudoers.d/$NEWUSER



apk add zsh


apk add wget curl


wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh


sudo sh install.sh


apk add zsh zsh-theme-powerlevel10k

apk add tar

wget https://www.zsh.org/pub/zsh-5.9.tar.xz

tar -xvf zsh-5.9

ln -s /usr/share/zsh/plugins/powerlevel10k ~/.local/share/zsh/plugins/

apk add shadow git

touch $USERNAME/.bashrc

echo "alias update='apk update && apk upgrade'" | sudo tee -a $USERNAME/.bashrc
echo "ipadurin koyrir command 'apk' (stendur fyri alpine linux package) commands :"
sleep 2

echo "koyrir nu comands 'apk update og apk upgrade'"
sleep 2

