#!/bin/bash

## Notes about script
## MINECRAFT_USER = The user that owns the minecraft server file.
## MINECRAFT_GROUP = The group that owns the minecraft server file.
## MINECRAFT_DIR = The directory where the minecraft server jar file is stored on your system.
## DESKTOP_FILE = Modified the shortcut for the minecraft server for Ubuntu systems.
## VERSION_FILE = A file which lives within minecraft server directory which only contains the current name of the server file. 
## ie; minecraft_server.1.14.4.jar
## This file will need to be created manually; initially.
## SERVER_FILE = Same as SERVER_VERSION, lists the latest version of the Minecraft server file.

#MINECRAFT_USER=jdelgado
#MINECRAFT_GROUP=jdelgado

if [ -z $MINECRAFT_USER ]
then
    read -p "Enter the username that owns the Minecraft Server directory: " $MINECRAFT_USER
fi

if [ -z $MINECRAFT_GROUP ]
then
    read -p "Enter the group that owns that Minecraft Server directory: " $MINECRAFT_GROUP
fi

### LEFT OFF HERE, WILL CONTINUE TOMOROW
if [ -z $(grep $MINECRAFT_USER /etc/passwd) ] || [ -z $(grep $MINECRAFT_GROUP /etc/group) ]
then
    echo You have entered an invalid user or group!
    exit 1
fi

MINECRAFT_DIR=/home/minecraft/minecraft
DESKTOP_FILE=/usr/share/applications/minecraft-server.desktop
VERSION_FILE=$MINECRAFT_DIR/version2.txt
CURL_OUT=$(curl -ks https://www.minecraft.net/en-us/download/server/ | egrep -i "href" | egrep -i "server.jar")
DOWNLOAD_URL=$(echo $CURL_OUT | sed 's/.*\"\(.*\)\".*/\1/' | tr -d '\r')
SERVER_FILE=$(echo $CURL_OUT | sed 's/.*>\(.*\)<\/a>/\1/'i | tr -d '\r')
SERVER_VERSION=$SERVER_FILE

if [ ! -e $MINECRAFT_DIR ]
then
    echo The directory $MINECRAFT_DIR does not exist!
    exit 1
fi

if [ ! -e $VERSION_FILE ]
then
    echo -e The file $VERSION_FILE does not exist!
    POSSIBLE_SERVER_NAME=$(ls $MINECRAFT_DIR/minecraft_server* | sort | tail -n 1 | xargs -0 basename)
    if [ -n $POSSIBLE_SERVER_NAME ]
    then
        read -p "I think your latest file is $POSSIBLE_SERVER_NAME, do you want me to create the version file for you? Enter 'y' for yes: " RESPONSE
        if [ $RESPONSE = "y" ] || [ $RESPONSE = "Y" ]
        then
            echo Creating $VERSION_FILE ...
            echo $POSSIBLE_SERVER_NAME >> $VERSION_FILE
            chown $MINECRAFT_USER:$MINECRAFT_GROUP $VERSION_FILE
            chmod 664 $VERSION_FILE
        else
            echo Ok then, create your own version file and re-run the script.
            exit 1
        fi 
    else
        exit 1
    fi
fi

if [ ! -r $VERSION_FILE ] 
then
    echo -e Script cannot read $VERSION_FILE
    exit 1
fi

CURRENT_VERSION=$(cat $VERSION_FILE | tr -d '\r')

if [ "$SERVER_VERSION" = "$CURRENT_VERSION" ]
then
   echo Your system is up-to-date
   echo Current Version: $SERVER_VERSION
   exit 0
else
   echo Your system is out-of-date
   curl -ks $DOWNLOAD_URL -o $SERVER_VERSION
   chmod 664 $SERVER_FILE
   chown $MINECRAFT_USER:$MINECRAFT_GROUP $SERVER_FILE
   mv $SERVER_VERSION $MINECRAFT_DIR
   sed -i "s/$CURRENT_VERSION/$SERVER_VERSION/g" $VERSION_FILE
   sed -i "s/$CURRENT_VERSION/$SERVER_VERSION/g" $DESKTOP_FILE
   echo Done! You now have the following version installed: $SERVER_VERSION
   exit 0
fi
