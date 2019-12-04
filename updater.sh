#!/bin/bash

## Notes about script
## MINECRAFT_USER = The user that owns the minecraft server file
## MINECRAFT_GROUP = The group that owns the minecraft server file
## MINECRAFT_DIR = The directory where the minecraft server jar file is stored on your system.
## DESKTOP_FILE = Modified the shortcut for the minecraft server for Ubuntu systems.
## VERSION_FILE = Is a file that must be created that only contains the current file name of the server file. ie; minecraft_server.1.14.4.jar

MINECRAFT_USER=jdelgado
MINECRAFT_GROUP=jdelgado
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
   chown $MINECRAFT_USER:$MINECRAFT_GROUP $SERVER_VERSION
   mv $SERVER_VERSION $MINECRAFT_DIR
   sed -i "s/$CURRENT_VERSION/$SERVER_VERSION/g" $VERSION_FILE
   sed -i "s/$CURRENT_VERSION/$SERVER_VERSION/g" $DESKTOP_FILE
   echo Done! You now have the following version installed: $SERVER_VERSION
fi
