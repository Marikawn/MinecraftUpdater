# Minecraft Updater

## Background
I created this bash script to automate the process of downloading/updating the Minecraft server JAR file.

The system I am using is Ubuntu 18.04.3 LTS (Bionic Beaver) which uses GNOME3. 
- I have created a user & group on my system named "minecraft"
- I have installed the Minecraft server within this user's home directory: /home/minecraft/
- Also within this minecraft server directory I created a simple text file named version.txt which only contains the currently installed minecraft file (ie; minecraft_server1.14.4.jar). 
- I created a GNOME3 Destkop shortcut file in the following location: /usr/share/applications/minecraft-server.desktop
  - See repository for sample copy of sample.

## Usage
To run this script simply execute it locally:

```
./updater.sh <user> <group> <minecraft_server_directory> <destkop_full_file_path>

OR

./updater.sh
Follow prompts
``` 

## Explanation of Variable
- $MINECRAFT_USER = The user that owns the minecraft server file.
- $MINECRAFT_GROUP = The group that owns the minecraft server file.
- $MINECRAFT_DIR = The directory where the minecraft server jar file is stored on your system.
- $DESKTOP_FILE = Modified the shortcut for the minecraft server for systems that use GNOME3.
- $VERSION_FILE = A file which lives within minecraft server directory which only contains the current name of the server file.  ie; minecraft_server.1.14.4.jar
  - This file will need to be created manually; initially. If not, the script will help you create this file.
- SERVER_FILE = Same as SERVER_VERSION, lists the latest version of the Minecraft server file.


If you have any questions about this script, feel free to e-mail me at: marikawn<at>gmail.com
