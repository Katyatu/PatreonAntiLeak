#! /bin/bash

##################################
#        Common Variables        #
##################################

INSTALLDIR="$HOME/.config/PAL"
TEMPDIR="/tmp/PAL"

##################################
#       Core Functionality       #
##################################

if [ -d $TEMPDIR ]; then
    for instancepid in $TEMPDIR/PIDs/*; do 
        if [ -f "$instancepid" ]; then 
            kill $(basename $instancepid)
            rm $instancepid
            sleep 2
        fi 
    done
    rm -r $TEMPDIR
fi