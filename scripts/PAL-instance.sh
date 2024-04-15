#!/bin/bash

##################################
#        Common Variables        #
##################################

INSTALLDIR="$HOME/.config/PAL"
TEMPDIR="/tmp/PAL"

# Clean Exit Handling
trap ctrl_c INT
function ctrl_c() {
    if [ $WEBHOOKMSGID ]; then
        printf "
Ctrl+C caught, exiting cleanly...
"
        mega-export -d $MEGADRIVEPATH
        curl --location --request DELETE "$WEBHOOKBOTURL/messages/$WEBHOOKMSGID"
        rm "$INSTALLDIR/instances/messageIDs/$INSTANCENAME"
    fi
    exit 1
}

##################################
#       Instance Specific        #
##################################

MEGADRIVEPATH=$1
HOURSTOWAIT=$2
WEBHOOKBOTURL=$3
INSTANCENAME=$4

##################################
#       Core Functionality       #
##################################

while :
do

    ## Remove existing MEGA share link
    if [[ ! $(mega-export $MEGADRIVEPATH) == *"Couldn't find"* ]]; then
        mega-export -d $MEGADRIVEPATH
    fi

    ## Greeting / Info
    printf "
======================================================================

PatreonAntiLeak Protection of MEGA folder \"$MEGADRIVEPATH\" is running...

Folder links will expire and be replaced every $HOURSTOWAIT hour(s).

This script loops indefinitely, use PAL-manager to control instances.

======================================================================

"

    ## Fetch dedicated bot messageID
    if [ ! -f "$INSTALLDIR/instances/messageIDs/$INSTANCENAME" ]; then

        ## Create new dedicated message if DNE
        WEBHOOKMSGID=$(curl -s --location "$WEBHOOKBOTURL?wait=true" --form "payload_json={\"content\":\"Refreshing...\"}" | jq --raw-output '.id')

        ## Save messageID for future use
        echo $WEBHOOKMSGID > "$INSTALLDIR/instances/messageIDs/$INSTANCENAME"

    else
        ## Load existing messageID
        WEBHOOKMSGID=$(cat "$INSTALLDIR/instances/messageIDs/$INSTANCENAME")

        ## If dedicated discord bot message no longer exists, re-create
        if [[ ! $(curl -s --location --request PATCH "$WEBHOOKBOTURL/messages/$WEBHOOKMSGID" \
                    --header 'Content-Type: application/x-www-form-urlencoded' \
                    --header 'Accept: application/json' \
                    --data-urlencode "content=Refreshing..." | jq --raw-output '.content') == "Refreshing..." ]]; then

            rm "$INSTALLDIR/instances/messageIDs/$INSTANCENAME"
            WEBHOOKMSGID=$(curl -s --location "$WEBHOOKBOTURL?wait=true" --form "payload_json={\"content\":\"Refreshing...\"}" | jq --raw-output '.id')
            echo $WEBHOOKMSGID > "$INSTALLDIR/instances/messageIDs/$INSTANCENAME"
        fi
    fi

    ## Share link specific variables
    RANDOMINT=0
    if [ -f $INSTALLDIR/control/settings/RANDOMINT ]; then
        RANDOMINT=$(shuf -i 1-900 -n 1)
        if [ $(shuf -i 1-2 -n 1) -eq 1 ]; then
            RANDOMINT=-$RANDOMINT
        fi
        EXPIREDATE=$(date -d "now + $HOURSTOWAIT hours + $RANDOMINT seconds")
    else
        EXPIREDATE=$(date -d "now + $HOURSTOWAIT hours")
    fi

    MEGARESPONSE=$(mega-export -a -f $MEGADRIVEPATH)
    MEGASHARELINK=$(echo $MEGARESPONSE | grep -oP 'http.?://\S+#')
    MEGASHAREKEY=$(echo $MEGARESPONSE | grep -oP '#\K\S+')

    if [ -f $INSTALLDIR/control/settings/SEPARATEKEY ]; then
        WEBHOOKMESSAGE="$MEGASHARELINK"
    else
        WEBHOOKMESSAGE="$MEGASHARELINK$MEGASHAREKEY"
    fi

    ## Editing the dedicated bot message with new share link
    curl -s --location --request PATCH "$WEBHOOKBOTURL/messages/$WEBHOOKMSGID" \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --header 'Accept: application/json' \
    --data-urlencode "content=$WEBHOOKMESSAGE" > /dev/null

    ## Updating info on the local terminal
    printf "Current URL:

	$MEGASHARELINK

Decryption Key:

	$MEGASHAREKEY

Expires on:

	$EXPIREDATE

Webhook message ID:

	$WEBHOOKMSGID
	
======================================================================

Sleeping until $EXPIREDATE ...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

"

    ## Sleeping for the requested time before looping back to start.
    sleep $(($HOURSTOWAIT * 60 * 60 + $RANDOMINT))

done