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

##########################
#                        #
# Ctrl+C caught, exiting #
# PAL-manager cleanly... #
#                        #
##########################

"
    exit 1
}

##################################
#       Core Functionality       #
##################################

while :
do
    clear

    printf "
################################
#                              #
# Welcome back to the manager  #
# of PatreonAntiLeak!          #
#                              #
# (Ctrl+C to exit at any time) #
#                              #
################################
"

    # Ensuring user is logged into MEGAcmd
    if [[ $(mega-whoami) == *"Not logged in."* ]]; then
        printf "
Your MEGA account is not logged in with MEGAcmd.

PAL requires a logged in MEGA user in order to do anything.

Please run 'mega-login <email> <password>' first before running PAL-manager.

    "
        exit 1
    else
        printf "
Current logged in MEGA user:
$(mega-whoami)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
           Remember!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Re-initialize PAL or 'sudo reboot'
after modifying any instances or
settings. Instances are persistent,
so changes are not applied until
after PAL is fully restarted. 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
    fi

        # If PAL is not initialized
    if [ ! -d $TEMPDIR ]; then
        printf "
PAL status: Offline

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
    else
        printf "
PAL status: Online

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"

    fi

    # Get user input
    read -p "
Control options:

[1] Create an instance
[2] Delete an instance

[3] Advanced Protection

[4] Re-initialize PAL (restart)
[5] De-initialize PAL (stop)

[7] View an instance's log

[9] Check for PAL update
[0] Uninstall PAL

[q] Exit the manager

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

What would you like to do? " choice

    case $choice in 
        # Launch the instance creation script
        [1] ) $INSTALLDIR/control/PAL-create.sh
            ;;

        # Launch the instance deletion script
        [2] ) $INSTALLDIR/control/PAL-delete.sh
            ;;

        # Launch the advaned protection script
        [3] ) $INSTALLDIR/control/PAL-advprot.sh
            ;;

        # Kill all running instances and relaunch
        [4] ) printf "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Killing any running instances ..."
            $INSTALLDIR/control/PAL-kill.sh

            printf " Done.
            
Re-initializing registered instances (wait 10s per instance) ..."

            $INSTALLDIR/control/PAL-init.sh

            printf " Done.
            
PAL has been restarted and all currently registered instances are running.

"           
            read -n 1 -s -r -p "Press any key to return to the PAL-manager ... "
            ;;

        # Kill all running instances
        [5] ) 
            if [ -d $TEMPDIR ]; then
                printf "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Killing any running instances ..."
                $INSTALLDIR/control/PAL-kill.sh

                printf " Done.
            
PAL has been brought offline. [4] Re-initialize PAL
or 'sudo reboot' to bring PAL back online.

"           
                read -n 1 -s -r -p "Press any key to return to the PAL-manager ... "
            else
                read -n 1 -s -r -p "
PAL is already offline.

Press any key to return to the PAL-manager ... "
            fi
            ;;

        # Launch the view instance log script
        [7] ) $INSTALLDIR/control/PAL-log.sh
            ;;

        # Launch the PAL update procedure
        [9] ) $INSTALLDIR/control/PAL-update.sh
            exit 0
            ;;

        # Launch the PAL self-removal script
        [0] ) $INSTALLDIR/control/PAL-uninstaller.sh
            exit 0
            ;;

        # Exit the manager
        ["q"] ) printf "
Until next time!

"
            exit 0
            ;;
        
        # Ignore any other input
        * ) 
            ;;
    esac
done