#!/bin/bash

SSID=$1
PWD=$2
echo "starting wifi autoconnecter for ssid:$SSID"
while :; do
  if [ $(networksetup -getairportpower en1| grep -c 'Off') -eq '1' ]; then
    echo "turning on Wi-Fi"
    $(networksetup -setairportpower en1 on)
  fi;
  if [ $(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan | grep -c $SSID) -ne '0' ]; then
    echo "wifi available for ssid:$SSID"
    if [ $(networksetup -getinfo Wi-Fi | grep -c 'IP address:') -ne '2' ]; then
      echo "wifi disconnected for ssid:$SSID"
      echo "connecting.."
      $(networksetup -setairportnetwork en1 $SSID $PWD)
    else
      other=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | awk -F':' '/ SSID/ {print $2}' | tr -d '')
      if [ $other != $SSID ]; then
        echo "attempting to disconnect from ssid:$other and switch to ssid:$SSID instead.."
        echo "connecting.."
        $(networksetup -setairportnetwork en1 $SSID $PWD)
      else
        echo "already connected to ssid:$SSID"
        ROUTER_IP=$(networksetup -getinfo Wi-Fi | grep 'Router' | head -n 1 | awk -F':' '{print $2}' | tr -d '')
        #ping google instead of router
        ROUTER_IP=www.google.com
        echo "pinging $ROUTER_IP"
        if [ $(ping -c1 -t 5 $ROUTER_IP | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1}') -eq '0' ]; then
          echo "router down for ssid:$SSID..restarting wifi"
          $(networksetup -setairportpower en1 off)
          $(networksetup -setairportpower en1 on)
        fi;
      fi;
    fi;
  fi;
  sleep 10;
done;
