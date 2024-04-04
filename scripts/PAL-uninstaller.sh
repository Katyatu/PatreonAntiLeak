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
# Welcome to the uninstaller   #
# of PatreonAntiLeak!          #
#                              #
# (Ctrl+C to exit at any time) #
#                              #
################################

"

if [ ! -d "$INSTALLDIR" ]; then
    printf "No existing installation was found, nothing to remove! Exiting...

"
    exit 1
fi

read -p "Here is a rundown of everything that will be removed:
~
├── .config
│   ├── PAL
│   └── systemd
│       └── user
│           ├── MEGAcmd-autostart.service
│           └── PAL-autostart.service
└── bin
    └── PAL-manager

Do you wish to proceed with the removal of PAL? (y/N) " yn

case $yn in 
	[yY] ) printf "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[1/5] Stopping all PAL processes ..."
        $INSTALLDIR/control/PAL-kill.sh

        printf " Done!

[2/5] Disabling MEGAcmd-autostart.service and PAL-autostart.service ..."
        systemctl -q --user disable MEGAcmd-autostart.service
        systemctl -q --user disable PAL-autostart.service

        printf " Done!

[3/5] Removing MEGAcmd-autostart.service and PAL-autostart.service from $HOME/.config/systemd/user ..."
        rm $HOME/.config/systemd/user/MEGAcmd-autostart.service
        rm $HOME/.config/systemd/user/PAL-autostart.service

        printf " Done!
        
[4/5] Removing PAL-manager from $HOME/bin ..."
        rm $HOME/bin/PAL-manager

        printf " Done!
        
[5/5] Removing PAL from $HOME/.config ..."
        rm -r $HOME/.config/PAL

        printf " Done!

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[OK] PAL has been fully removed from your system. Run 'sudo reboot' to finalize.

Come back soon!
        
"
        ;;

	* ) printf "
Cancelling, no changes were made.
    
"
		exit
        ;;
esac