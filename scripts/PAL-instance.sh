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

This script loops indefinitely, use PAK-manager to control instances.

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
    EXPIREDATE=$(date -d "now + $HOURSTOWAIT hours")
    MEGASHARELINK=$(mega-export -a -f $MEGADRIVEPATH | grep -oP 'http.?://\S+')
    WEBHOOKMESSAGE="$MEGASHARELINK"

    ## Editing the dedicated bot message with new share link
    curl -s --location --request PATCH "$WEBHOOKBOTURL/messages/$WEBHOOKMSGID" \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --header 'Accept: application/json' \
    --data-urlencode "content=$WEBHOOKMESSAGE" > /dev/null

    ## Updating info on the local terminal
    printf "Current URL:

	$MEGASHARELINK

Expires on:

	$EXPIREDATE

Webhook message ID:

	$WEBHOOKMSGID
	
======================================================================

Sleeping for $HOURSTOWAIT hour(s), gn zzz...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

"

    ## Sleeping for the requested time before looping back to start.
    sleep $(($HOURSTOWAIT * 60 * 60))

done