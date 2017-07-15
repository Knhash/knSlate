#! /bin/bash
set -e

# knSlate installation script

# This script installs the GRUB2 theme in /boot/grub/themes/, /boot/grub2/themes/ or /grub/themes/
# depending on the distribution.

# Set variables
Theme_Name="knSlate"                            # The theme will be installed in a dir with this name. Avoid spaces.
Theme_Definition_File="theme.txt"               # Filename of theme definition file.
Theme_Resolution="any"                          # The resolution the theme was designed to show best at, 640x480, 1024x768 etc,
                                                # or "any" for any resolution (resolution independent).

Inst_Dir=$(dirname $0)
Grub_Dist_Dirs="/grub /boot/grub /boot/grub2"   # Directories must be in this order.
let Grub_Min_Version=198                        # Do not change this.
Grub_File="/etc/default/grub"
Grub_Dir=
mkConfig_File=

echo "knSlate installation"
echo ""

# Check that the script is being run as root.
if [[ $(id -u) != 0 ]]; then
    echo "Please run this script with root privileges."
    exit 0
fi

# Get GRUB's installation directory.
for i in $Grub_Dist_Dirs; do
    if [[ -d $i ]]; then
        Grub_Dir=$i
    fi
done

# Exit this script if we could not locate GRUB's installation directory.
if [[ -z $Grub_Dir ]]; then
    echo "Could not locate GRUB's installation directory."
    exit 0
fi

# Exit the script if GRUB's version is < 1.98
if [[ -f $(which grub2-install) ]]; then
    Grub_Version_Long=$(grub2-install --version)
elif [[ -f $(which grub-install) ]]; then
    Grub_Version_Long=$(grub-install --version)
else
    echo 'Could not locate grub-install or grub2-install in your path.'
    exit 0
fi
Grub_Version=$(echo $Grub_Version_Long | sed 's,[[:alpha:][:punct:][:blank:]],,g')
if (( ${Grub_Version:0:3} < Grub_Min_Version )); then
    echo "GRUB must be at least version ${Grub_Min_Version:0:1}.${Grub_Min_Version:1:2}."
    echo "The installed version is ${Grub_Version:0:1}.${Grub_Version:1:2}."
    exit 0
fi

# Check that /etc/default/grub exists.
if [[ ! -f $Grub_File ]]; then
    echo "Could not find $Grub_File"
    exit 0
fi

# Check that GRUB's mkconfig script file exists.
mkConfig_File=$(which ${Grub_Dir##*/}-mkconfig) || \
(echo "GRUB's mkconfig script file was not found in your path." && exit 0)

# Ask for desired resolution if set to "any"
if [[ $Theme_Resolution = "any" ]]; then
    echo ""
    echo -n "Enter Resolution as 1024x768, 800x600, 1600x1200, etc. :"
    read Theme_Resolution
fi

# Create theme directory.  If directory already exists, ask the user if they would like
# to overwrite the contents with the new theme or create a new theme directory.
Theme_Dir=$Grub_Dir/themes/$Theme_Name
while [[ -d $Theme_Dir ]]; do
    echo "Directory $Theme_Dir already exists!"
    echo -n "Would you like to overwrite it's contents or create a new directory? [o/c] "
    read Response
    case $Response in
        c|create)
            echo -n "Please enter a new name for the theme's directory: "
            read Response
            Theme_Dir=$Grub_Dir/themes/$Response;;
        o|overwrite)
            echo -n "This will delete all files in $Theme_Dir. Are you sure? [y/n] "
            read Response
            case $Response in
                y|yes)
                    rm -r $Theme_Dir;;
                *)
                    exit 0;;
            esac;;
        *)
            exit 0;;
    esac
done
mkdir -p $Theme_Dir

# Copy the theme's files to the theme's directory.
for i in $Inst_Dir/*; do
    cp -r $i $Theme_Dir/$(basename $i)
done

# Change GRUB's resolution to match that of the theme.
if [[ $Theme_Resolution != "any" ]]; then
    i=$(sed -n 's,^#\?GRUB_GFXMODE=,&,p' $Grub_File)
    if [[ -z $i ]]; then
        echo -e "\nGRUB_GFXMODE=$Theme_Resolution" >>$Grub_File
    else
        sed "s,^#\?GRUB_GFXMODE=.*,GRUB_GFXMODE=$Theme_Resolution," <$Grub_File >$Grub_File.~
        mv $Grub_File.~ $Grub_File
    fi
fi

# Ask the user if they would like to set the theme as their new theme.
echo -n "Would you like to set this as your new theme? [y/n] "
read Response
if [[ $Response = yes || $Response = y ]]; then
    i=$(sed -n 's,^#\?GRUB_THEME=,&,p' $Grub_File)
    if [[ -z $i ]]; then
        echo -e "\nGRUB_THEME=$Theme_Dir/$Theme_Definition_File" >>$Grub_File
    else
        sed "s,^#\?GRUB_THEME=.*,GRUB_THEME=$Theme_Dir/$Theme_Definition_File," <$Grub_File >$Grub_File.~
        mv $Grub_File.~ $Grub_File
    fi
    $($mkConfig_File -o $Grub_Dir/grub.cfg)     # Generate new grub.cfg
fi
exit 0

#
# Credits: Towheed Mohammed