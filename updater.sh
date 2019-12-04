#!/bin/bash

MINECRAFT_DIR=/home/minecraft/minecraft/
DESKTOP_FILE=/usr/share/applications/minecraft-server.desktop
VERSION_FILE=version.txt
CURL_OUT=$(curl -ks https://www.minecraft.net/en-us/download/server/ | egrep -i "href" | egrep -i "server.jar")
DOWNLOAD_URL=$(echo $CURL_OUT | sed 's/.*\"\(.*\)\".*/\1/' | tr -d '\r')
SERVER_VERSION=$(echo $CURL_OUT | sed 's/.*>\(.*\)<\/a>/\1/'i | tr -d '\r')
CURRENT_VERSION=$(cat $VERSION_FILE | tr -d '\r')

if [ "$SERVER_VERSION" = "$CURRENT_VERSION" ]
then
   echo Your system is up-to-date
   echo Current Version: $SERVER_VERSION
else
   echo Your system is out-of-date
   curl -ks $DOWNLOAD_URL -o $SERVER_VERSION
   chmod 664 $SERVER_VERSION
   chown jdelgado:jdelgado $SERVER_VERSION
   mv $SERVER_VERSION $MINECRAFT_DIR
   sed -i "s/$CURRENT_VERSION/$SERVER_VERSION/g" $VERSION_FILE
   sed -i "s/$CURRENT_VERSION/$SERVER_VERSION/g" $DESKTOP_FILE
   echo Done! You now have the following version installed: $SERVER_VERSION
fi
