#!/bin/bash

sudo nohup killall naga > /dev/null 2>&1 &

sudo echo "Checking requirements..."
command -v xdotool >/dev/null 2>&1 || { tput setaf 1; echo >&2 "I require xdotool but it's not installed! Aborting."; tput sgr0; exit 1; }

echo "Compiling code..."
cd src
g++ -O3 -std=c++11 naga.cpp -o naga

if [ ! -f ./naga ]; then
	tput setaf 1; echo "Error at compile! Ensure you have g++ installed. !!!Aborting!!!"
	tput sgr0;
	exit 1
fi

echo "Copying files..."
sudo mv naga /usr/local/bin/
sudo chmod 755 /usr/local/bin/naga

cd ..

groupadd -f razer
sudo cp nagaXinputStart.sh /usr/local/bin/
sudo chmod 755 /usr/local/bin/nagaXinputStart.sh

for u in $(sudo awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd)
do
	sudo gpasswd -a "$u" razer
	_dir="/home/${u}/.naga"
	sudo mkdir -p $_dir
	if [ -d "$_dir" ]
	then
		sudo cp -r -n -v "keyMap.txt" "$_dir"
		sudo chown -R $(id -un $u):users "$_dir"
	fi
done
if [ -d "/root" ];
then
	sudo gpasswd -a "root" razer
	sudo mkdir -p /root/.naga
	sudo cp -r -n -v "keyMap.txt" "/root/.naga"
fi

echo 'KERNEL=="event[0-9]*",SUBSYSTEM=="input",GROUP="razer",MODE="640"' > /tmp/80-naga.rules

sudo mv /tmp/80-naga.rules /etc/udev/rules.d/80-naga.rules

naga --start

tput setaf 2; echo "Please add (naga.desktop or a script with naga -start) to be executed\nwhen your window manager starts."
tput sgr0;
