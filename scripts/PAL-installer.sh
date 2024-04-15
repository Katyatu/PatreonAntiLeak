#! /bin/bash

##################################
#        Common Variables        #
##################################

INSTALLDIR="$HOME/.config/PAL"
TEMPDIR="/tmp/PAL"

# Clean Exit Handling
trap ctrl_c INT
function ctrl_c() {
    printf "

############################
#                          #
# Ctrl+C caught, exiting   #
# PAL-installer cleanly... #
#                          #
############################

"
    exit 1
}

##################################
#       Core Functionality       #
##################################

    clear

    printf "
################################
#                              #
# Welcome to the installer of  #
# PatreonAntiLeak!             #
#                              #
# (Ctrl+C to exit at any time) #
#                              #
################################

"

# Check for existing installation
if [ -d "$INSTALLDIR" ]; then
    printf "Existing installation found, please run the uninstaller inside of PAL-manager first,
as file structure consistency between PAL versions is crucial for bug-free usage.

"
    exit 1
fi

# Check for required dependancies
if [[ $(jq -V) == "" || $(mega-version) == "" ]]; then
    printf "
Required dependancies are not met. Refer to the \"Usage\" section of the README
and run the command listed under \"Installing Required Dependancies\".

"
    exit 1
fi

read -p "Here is a rundown of everything that will be installed:
~/
├── .config/
│   ├── PAL/
│   │   ├── control/
│   │   │   ├── PAL-advprot.sh
│   │   │   ├── PAL-create.sh
│   │   │   ├── PAL-delete.sh
│   │   │   ├── PAL-init.sh
│   │   │   ├── PAL-instance.sh
│   │   │   ├── PAL-kill.sh
│   │   │   ├── PAL-log.sh
│   │   │   ├── PAL-uninstaller.sh
│   │   │   ├── PAL-update.sh
│   │   │   └── settings/
│   │   └── instances/
│           └── messageIDs/
│   └── systemd/
│       └── user/
│           ├── MEGAcmd-autostart.service
│           └── PAL-autostart.service
└── bin/
    └── PAL-manager

Do you wish to proceed with the installation of PAL? (y/N) " yn

case $yn in 
	[yY] ) printf "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[1/7] Creating new installation ..."
        mkdir $INSTALLDIR

        printf " Done!
        
[2/7] Fetching latest release ..."
        wget -qO- "$(curl -s https://api.github.com/repos/katyatu/patreonantileak/releases/latest | jq --raw-output '.assets[0].browser_download_url')" | tar x -J -C $INSTALLDIR

        printf " Done!
        
[3/7] Setting up internal folder structure ..."
        mkdir $INSTALLDIR/control
        mkdir $INSTALLDIR/control/settings
        mkdir $INSTALLDIR/instances
        mkdir $INSTALLDIR/instances/messageIDs

        printf " Done!
        
[4/7] Installing control scripts ..."
        mv $INSTALLDIR/PAL-advprot.sh $INSTALLDIR/control
        mv $INSTALLDIR/PAL-create.sh $INSTALLDIR/control
        mv $INSTALLDIR/PAL-delete.sh $INSTALLDIR/control
        mv $INSTALLDIR/PAL-init.sh $INSTALLDIR/control
        mv $INSTALLDIR/PAL-instance.sh $INSTALLDIR/control
        mv $INSTALLDIR/PAL-kill.sh $INSTALLDIR/control
        mv $INSTALLDIR/PAL-log.sh $INSTALLDIR/control
        mv $INSTALLDIR/PAL-uninstaller.sh $INSTALLDIR/control
        mv $INSTALLDIR/PAL-update.sh $INSTALLDIR/control

        printf " Done!
        
[5/7] Installing command PAL-manager into $HOME/bin ..."
        if [ ! -d "$HOME/bin" ]; then
            mkdir $HOME/bin
        fi
        mv $INSTALLDIR/PAL-manager.sh $HOME/bin/PAL-manager

        printf " Done!
        
[6/7] Installing MEGAcmd-autostart.service and PAL-autostart.service into $HOME/.config/systemd/user ..."
        if [ ! -d "$HOME/.config/systemd/user" ]; then
            mkdir -p $HOME/.config/systemd/user
        fi
        mv $INSTALLDIR/MEGAcmd-autostart.service $HOME/.config/systemd/user
        mv $INSTALLDIR/PAL-autostart.service $HOME/.config/systemd/user

        printf " Done!
        
[7/7] Enabling MEGAcmd-autostart.service and PAL-autostart.service ..."
        systemctl -q --user enable MEGAcmd-autostart.service
        systemctl -q --user enable PAL-autostart.service

        printf " Done!
        
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[OK] PAL has been successfully installed! Run 'sudo reboot' to reboot so PAL can properly initialize.

Afterwards, use PAL-manager to interact with PAL and its instances.
        
See you soon!

"
        ;;

	* ) printf "
Cancelling, no changes were made.
    
"
		exit
        ;;
esac