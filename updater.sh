#!/bin/bash
# Sample Usage
# ./updater.sh minecraftuser minecraftgroup /home/minecraftuser/serverdirectory /usr/share/applications/minecraft-server.desktop

if [ "$#" -eq 4 ]
then
    MINECRAFT_USER=$1
    MINECRAFT_GROUP=$2
    MINECRAFT_DIR_TMP=$3
    MINECRAFT_DIR=$(echo "$MINECRAFT_DIR_TMP" | sed 's:/*$::')
    DESKTOP_FILE=$4
fi

if [ -z $MINECRAFT_USER ]
then
    read -ep "Enter the username that owns the Minecraft Server directory: " MINECRAFT_USER
fi

if [ -z $MINECRAFT_GROUP ]
then
    read -ep "Enter the group that owns that Minecraft Server directory: " MINECRAFT_GROUP
fi

if [ -z "$(grep $MINECRAFT_USER /etc/passwd)" ]
then
    echo You have entered an invalid user: $MINECRAFT_USER
    exit 1
fi

if [ -z "$(grep $MINECRAFT_GROUP /etc/group)" ]
then
    echo You have entered an invalid group: $MINECRAFT_GROUP
    exit 1
fi

if [ -z $MINECRAFT_DIR ]
then
    read -ep "Enter the Minecraft server directory: " MINECRAFT_DIR_TMP
    MINECRAFT_DIR=$(echo "$MINECRAFT_DIR_TMP" | sed 's:/*$::')
    if [ ! -e $MINECRAFT_DIR ]
    then
        echo The directory $MINECRAFT_DIR does not exist!
        exit 1
    fi
fi

if [ -z $DESKTOP_FILE ]
then
    read -ep "Enter the full path to your Desktop shortcut file: " DESKTOP_FILE
    if [ ! -e $DESKTOP_FILE ]
    then
        echo I can\'t find the $DESKTOP_FILE. If you don\'t have one, see Github repository for sample and place it within the /usr/share/applications/ directory.
        exit 1
    fi
fi

VERSION_FILE=$MINECRAFT_DIR/version.txt
CURL_OUT=$(curl -ks https://www.minecraft.net/en-us/download/server/ | egrep -i "href" | egrep -i "server.jar")
DOWNLOAD_URL=$(echo $CURL_OUT | sed 's/.*\"\(.*\.jar\)\".*/\1/' | tr -d '\r')
SERVER_FILE=$(echo $CURL_OUT | sed 's/.*>\(.*\)<\/a>/\1/'i | tr -d '\r')
SERVER_VERSION=$SERVER_FILE

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
   echo Latest Version is $SERVER_FILE
   curl -ks $DOWNLOAD_URL -o $MINECRAFT_DIR/$SERVER_VERSION
   if [ -e $MINECRAFT_DIR/$SERVER_VERSION ]
   then
       chmod 664 $MINECRAFT_DIR/$SERVER_FILE
       chown $MINECRAFT_USER:$MINECRAFT_GROUP $MINECRAFT_DIR/$SERVER_FILE
       sed -i "s/$CURRENT_VERSION/$SERVER_VERSION/g" $VERSION_FILE
       sed -i "s/$CURRENT_VERSION/$SERVER_VERSION/g" $DESKTOP_FILE
       echo Done! You now have the following version installed: $SERVER_VERSION
       exit 0   
   else
    echo $MINECRAFT_DIR/$MINECRAFT_VERSION Doen\'t exist! Something went wrong with the download.   
    echo $DOWNLOAD_URL
    exit 1
   fi
fi
