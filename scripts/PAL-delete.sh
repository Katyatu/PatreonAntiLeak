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
# PAL-delete cleanly...  #
#                        #
##########################"
    exit 1
}

##################################
#       Core Functionality       #
##################################

while :
do
    clear

    # If no instances exist
    if (( $(ls -p $INSTALLDIR/instances | grep -v / | wc -l) < 1 )); then
        clear
        read -n 1 -s -r -p "
########################################
#                                      #
# Welcome to the PAL instance deleter! #
#                                      #
# No instances were found, press any   #
# key to return to the manager.        #
#                                      #
########################################

"
        exit 2
    fi

    # If instances were found
    printf "
########################################
#                                      #
# Welcome to the PAL instance deleter! #
#                                      #
# Let\'s get started...                 #
#                                      #
# (Ctrl+C to exit at any time)         #
#                                      #
########################################
"

    # Get user input for instance selection
    printf "
Here are the names of all your configured instances:

"
    ls -p $INSTALLDIR/instances | grep -v /
    read -p "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Which instance do you wish to delete? ('q' to exit): " choice

    # User choosing to exit
    if [[ $choice == "q" ]]; then
        exit 0
    fi

    # User input doesn't match any existing instances
    if [[ $(find $INSTALLDIR/instances/* -name "$choice" 2>/dev/null) == "" ]]; then
        read -n 1 -s -r -p "
    [Err] $choice doesn't match any of the existing instance names.

    Make sure you enter in the exact name you see listed.

    Press any key to try again ... "
    # User input matches existing instance, issue confirmation
    else
        read -p "
Instance $choice selected, do you wish to proceed with deletion? (y/N) " yn

        # Delete user specified instance
        if [[ $yn == "y" || $yn == "Y" ]]; then
            rm $INSTALLDIR/instances/$choice
            if [ -f "$INSTALLDIR/instances/messageIDs/$choice" ]; then
                rm $INSTALLDIR/instances/messageIDs/$choice
            fi
            printf "
    [OK] Instance $choice was deleted.
"
            # If user wants to delete more, loop to start
            read -p "
Would you like to delete another instance? (y/N) " yn

            if [[ $yn == "y" || $yn == "Y" ]]; then
                continue
            else
                exit 0
            fi
        fi
    fi
done