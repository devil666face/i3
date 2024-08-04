#!/bin/bash
# /usr/share/sddm/themes
sudo apt-get install sddm
sudo systemctl disable gdm3
sudo systemctl enable sddm
sudo mkdir /etc/sddm.conf.d -p
sudo cp sddm.conf /etc/sddm.conf.d/sddm.conf
sudo cp -r ../Sddm /usr/share/sddm/themes
