#! /bin/bash

PALVERSION="1.1"

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
# PAL-update cleanly...    #
#                          #
############################

"
    exit 1
}

##################################
#       Core Functionality       #
##################################

function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

printf "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Checking the PatreonAntiLeak repository for updates...
"
REPOVERSION=$(curl -s https://api.github.com/repos/katyatu/patreonantileak/releases/latest | jq --raw-output '.tag_name')

if [ $(version $PALVERSION) -lt $(version $REPOVERSION) ]; then
    read -p "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Current PAL Version: $PALVERSION
Latest PAL Version: $REPOVERSION

An update is available!

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Would you like to update your local PAL to the latest version? (y/N) " yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        # Save instance configs
        RANDOMID=$RANDOM
        printf "
Moving instance configs to a safe place... "
        cp -r $INSTALLDIR/instances $HOME/PAL-$RANDOMID

        # Uninstall old PAL
        read -n 1 -s -r -p " Done.
        
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PAL $PALVERSION now needs to be removed, follow through with the following uninstaller.

Press any key to proceed ... "
        $INSTALLDIR/control/PAL-uninstaller.sh
        # If user declines uninstall
        if [ -d $INSTALLDIR ]; then
            printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PAL was not uninstalled, assuming user changed their mind, cancelling update.
            
"
            rm -r $HOME/PAL-$RANDOMID
            exit 1
        fi

        # Install new PAL
        read -n 1 -s -r -p "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PAL $REPOVERSION will now be fetched and installed, follow through with the following installer.
        
Press any key to proceed ... "
        wget -q https://raw.githubusercontent.com/Katyatu/PatreonAntiLeak/main/scripts/PAL-installer.sh &&
        chmod +x PAL-installer.sh &&
        ./PAL-installer.sh &&
        rm PAL-installer.sh
        # If user declined install
        if [ ! -d $INSTALLDIR ]; then
            printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PAL was not installed, assuming user changed their mind, cancelling re-installation."
            rm -r $HOME/PAL-$RANDOMID
            exit 1
        fi

        # Move saved instance configs back
        printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Moving instance configs back to where they were... "
        mv $HOME/PAL-$RANDOMID/* $INSTALLDIR/instances
        rmdir $HOME/PAL-$RANDOMID

        printf " Done.
        
PAL update completed successfully! Performing a 'sudo reboot' is strongly advised.

"
    else
        read -n 1 -s -r -p  "
Declining update, staying up version $PALVERSION
                    
Press any key to exit ... 

"
        fi
else
    read -n 1 -s -r -p  "
Current version $PALVERSION is the latest, no updates available.
        
Press any key to exit ... 

"
fi