#!/bin/bash

sudo networksetup -createnetworkservice AdHoc lo0
sudo networksetup -setmanual AdHoc 192.168.30.88 255.255.255.255

# remove the network configuration files, so that the system can regenerate them fresh at next boot
#sudo rm /Library/Preferences/SystemConfiguration/NetworkInterfaces.plist
#sudo rm /Library/Preferences/SystemConfiguration/preferences.plist
#sudo reboot