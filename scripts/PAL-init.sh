#! /bin/bash

##################################
#        Common Variables        #
##################################

INSTALLDIR="$HOME/.config/PAL"
TEMPDIR="/tmp/PAL"
if [ ! -d $TEMPDIR ]; then
    mkdir $TEMPDIR
    mkdir $TEMPDIR/PIDs
fi

##################################
#       Core Functionality       #
##################################

echo "Init started" > $TEMPDIR/init.log

mega-reload >> $TEMPDIR/init.log

for name in $INSTALLDIR/instances/*; do 
    if [ -f "$name" ]; then 
        path=$(cat $name | jq --raw-output '.path')
        hours=$(cat $name | jq --raw-output '.hours')
        url=$(cat $name | jq --raw-output '.url')
        printf "Instance $name is launching...
        
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" > $TEMPDIR/$(basename $name).log
        $INSTALLDIR/control/PAL-instance.sh $path $hours $url $(basename $name) >> $TEMPDIR/$(basename $name).log &
        touch $TEMPDIR/PIDs/$!
        echo "$name launched" >> $TEMPDIR/init.log
        sleep 10
    fi 
done

echo "Init finished." >> $TEMPDIR/init.log