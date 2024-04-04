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
# PAL-create cleanly...  #
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
########################################
#                                      #
# Welcome to the PAL instance creator! #
#                                      #
# Let\'s get started...                 #
#                                      #
# (Ctrl+C to exit at any time)         #
#                                      #
########################################
"

    ##################################
    #    Name Input & Validation     #
    ##################################

    VALIDNAME=false
    while [ $VALIDNAME = false ]
    do 

        # Get user input for instance name
        read -p "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

              Step 1 of 4

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enter a name for this instance (alphanumeric only): " name

        # If instance name already exists
        if [ -f "$INSTALLDIR/instances/$name" ]; then
            printf "
    [Err] An instance with name $name already exists. Delete it with the \'PAL-delete\' command or pick another name.
"

        # If user input is not alphanumeric
        elif [[ ! $name =~ ^[a-zA-Z0-9][-a-zA-Z0-9]{0,61}[a-zA-Z0-9]$ ]]; then
            printf "
    [Err] Names can only contain letters and numbers, spaces and symbols are not allowed.
"

        # Save valid name
        else
            VALIDNAME=true
            printf "
    [OK] \"$name\" is available will be assigned as this instance's name.
"
        fi
    done


    ##################################
    #  MEGA Path Input & Validation  #
    ##################################

    CREATEMEGAFOLDER=false
    VALIDPATH=false
    while [ $VALIDPATH = false ]
    do

        # Get user input for drive path
        read -p "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

              Step 2 of 4

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is your current MEGA cloud drive's tree structure.
(Note: the "." is the root, if nothing else shows, your drive is empty).

$(mega-tree)

Enter the absolute path of the MEGA folder you want this instance to manage link sharing for (e.g. /Patreon/Tier1): " path

        # If user input points to the root
        if [[ $path == "/" || $path == "" ]]; then
            printf "
    [Err] Using the root of your cloud drive (/) is a security risk and thus not allowed. Please specify a non-root path (e.g. /<foldername>/<optionalsubfolders>/...).
"

        # If user input is valid but path DNE on the drive
        elif [[ $(mega-ls $path) == *"Couldn't find"* ]]; then
            printf "
    [OK] Couldn't find the path \"$path\" on your MEGA cloud drive, it will be created for you at the end of this setup.
"
            CREATEMEGAFOLDER=true
            VALIDPATH=true

        # If user input is valid and path exists on the drive
        else
            printf "
    [OK] Existing folder found! \"$path\" will be targeted by this instance. Do NOT assign this folder to more than one instance.
"
            VALIDPATH=true
        fi
    done

    ##################################
    #    Hours Input & Validation    #
    ##################################

    VALIDHOURS=false
    while [ $VALIDHOURS = false ]
    do 
        # Get user input for delay time
        read -p "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

              Step 3 of 4

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enter the number of hours you want the instance to wait before it deletes/generates a new share link (whole numbers only and >= 1): " hours
    
        # Accept whole numbers only
        [[ $hours =~ ^[0-9]+$ ]] || { printf "
    [Err] Invalid input. Only whole numbers greater than or equal to 1 are accepted.
"; continue; }

        # If user input is within a safe range
        if ((hours >= 1 && hours <= 100)); then
            VALIDHOURS=true
            printf "
    [OK] This instance will delete and generate a new \"$path\" share link every $hours hour(s).
"

        # If user input is outside of a safe range
        else
            printf "
    [Err] Invalid input. Only whole numbers greater than or equal to 1 are accepted.
"
        fi
    done

    ##################################
    #     Bot Input & Validation     #
    ##################################

    VALIDBOT=false
    while [ $VALIDBOT = false ]
    do 
        CONFIRMCODE=$RANDOM

        # Get user input for webhook bot
        read -p "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

              Step 4 of 4

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enter the url of the Discord Webhook Bot you setup in your Discord server channel of choice: " url

        # Bot URL validation
        printf "
Attempting to connect to the bot..."

        # API calling attempt
        URLRESPONSE=$(curl -s --location "$url?wait=true" \
        --form "payload_json={\"content\":\"$CONFIRMCODE\"}")
        WEBHOOKMSGID=$(echo $URLRESPONSE | jq --raw-output '.id')
        WEBHOOKCONTENT=$(echo $URLRESPONSE | jq --raw-output '.content')

        # If API call is successful
        if [[ $WEBHOOKCONTENT == $CONFIRMCODE ]]; then

            # Bot ownership confirmation
            read -p " Connected!

Confirmation code posted. Ownership confirmation is required. Please go to your Discord channel and insert your bot's code here: " code

            # If user input matches internal gen'd code
            if [[ $code == $CONFIRMCODE ]]; then
                printf "
    [OK] Ownership confirmed! This bot will be targeted by this instance. Do NOT assign this bot to more than one instance.
"
                VALIDBOT=true
                curl --location --request DELETE "$url/messages/$WEBHOOKMSGID"

            # If user input does not match internal gen'd code
            else
                printf "
    [Err] Code mismatch. Restarting bot registration...
"
                curl --location --request DELETE "$url/messages/$WEBHOOKMSGID"
            fi

        # If API call fails
        else
            printf "

    [Err] Connection failed. Check if you copied the right URL and try again.
"
        fi
    done


    ##################################
    #     Instance Finalization      #
    ##################################

    # Create MEGA folder if it was not found previously
    if [ $CREATEMEGAFOLDER = true ]; then
        mega-mkdir -p "$path"
        printf "
    [OK] MEGA folder \"$path\" was created and will be targeted by this instance. Do NOT assign this folder to more than one instance.
"
    fi

    # Display finalized instance info
    printf "
###################################################
#                                                 #
# Creating new instance with the following config #
#                                                 #
###################################################

    Instance Name: \"$name\"

    Targeted MEGA Drive Path: \"$path\"

    Link Rotation Period: $hours hour(s)

    Targeted Discord Webhook Bot: $url
"

    # Saving instance config to $INSTALLDIR/instances
    printf "{
    \"path\": \"$path\",
    \"hours\": \"$hours\",
    \"url\": \"$url\"
}
" > $INSTALLDIR/instances/$name

    ##################################
    #    End of Instance Creation    #
    ##################################

    printf "
######################################
#                                    #
# PAL instance created successfully! #
#                                    #
######################################
"

    # If user wants to create more, loop to start
    read -p "
Would you like to create another instance? (y/N) " yn

    if [[ $yn == "y" || $yn == "Y" ]]; then
        continue
    else
        exit 0
    fi

done