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
