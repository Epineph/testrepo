#!/bin/bash



echo "ipadurin koyrir command 'apk' (stendur fyri alpine linux package) commands :"
sleep 2

echo "koyrir nu comands 'apk update og apk upgrade'"
sleep 2

apk update

apk upgrade

"echo installerar bash um tu ikki longu hevur"
sleep 2

apk add bash


echo "fyri at kanna hvorjar shells tu hevur, kanst tu koyra command: 'cat /etc/shells'"

sleep 2

echo "hesar shells hevur tu nu:"
sleep 1

cat /etc/shells

sleep 2

echo "downloadar bash completion"

apk add bash-completion


cat /etc/bash/bash_completion.sh

echo "geri brukari philip"
echo "um tad ikki riggar, so stendur ein alternativur mati i scriptinum"

adduser -g "philip" philip

adduser philip wheel

apk add doas

echo "permit persist :wheel" | sudo tee -a /etc/doas.d/doas.conf

apk add sudo
NEWUSER='philip'
adduser -g "${NEWUSER}" $NEWUSER
echo "$NEWUSER ALL=(ALL) ALL" > /etc/sudoers.d/$NEWUSER && chmod 0440 /etc/sudoers.d/$NEWUSER



echo "downloadar zsh"
sleep 2


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

touch /home/philip/.bashrc

echo "alias update='apk update && apk upgrade'" | sudo tee -a /home/philip/.bashrc
