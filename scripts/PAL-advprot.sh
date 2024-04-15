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
# PAL-advprot cleanly...   #
#                          #
############################

"
    exit 1
}

##################################
#       Core Functionality       #
##################################

while :
do
    clear

    if [ -f $INSTALLDIR/control/settings/SEPARATEKEY ]; then
        SEPARATEKEY="Enabled"
    else
        SEPARATEKEY="Disabled"
    fi
    if [ -f $INSTALLDIR/control/settings/RANDOMINT ]; then
        RANDOMINT="Enabled"
    else
        RANDOMINT="Disabled"
    fi

    printf "
################################
#                              #
# Welcome to the advanced      #
# protection settings manager  #
# of PatreonAntiLeak!          #
#                              #
# (Ctrl+C to exit at any time) #
#                              #
################################
"

    # Get user input
    read -p "
Control options:

[1] Separate decryption key from share URL - [$SEPARATEKEY]
[2] Add a random offset to all instance wait times - [$RANDOMINT]

[4] Change the decryption key for an instance's folder

[h] List the full explanation for each option
[q] Go back to the manager

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

What would you like to do? " choice

    case $choice in 
        # Enable/disable the Separate Key setting
        [1] ) 
            if [ $SEPARATEKEY = "Enabled" ]; then
                rm $INSTALLDIR/control/settings/SEPARATEKEY
            else
                touch $INSTALLDIR/control/settings/SEPARATEKEY
            fi
            ;;

        # Enable/disable the Random Interval setting
        [2] ) 
            if [ $RANDOMINT = "Enabled" ]; then
                rm $INSTALLDIR/control/settings/RANDOMINT
            else
                touch $INSTALLDIR/control/settings/RANDOMINT
            fi
            ;;

        # Execute the Decryption Key Refresh process
        [4] ) printf "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here are the names of all your configured instances:

"
            ls -p $INSTALLDIR/instances | grep -v /
            read -p "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Which instance's MEGA folder decryption key
do you want to refresh? ('q' to exit): " choice

            # User choosing to exit
            if [[ $choice == "q" ]]; then
                continue

            # User input doesn't match any existing instances
            elif [[ $(find $INSTALLDIR/instances/* -name "$choice" 2>/dev/null) == "" ]]; then
                read -n 1 -s -r -p "
    [Err] $choice doesn't match any of the existing instance names.

    Make sure you enter in the exact name you see listed.

    Press any key to return ... "

            # User input matches existing instance
            else
                path=$(cat $INSTALLDIR/instances/$choice | jq --raw-output '.path')
                
                printf "
    Renaming MEGA folder $path to $path-old ... "
                mega-mv $path $path-old
                
                printf "Done.
                
    Creating new MEGA folder $path ... "
                mega-mkdir $path
                
                printf "Done.
                
    Moving contents from MEGA folder $path-old to $path ... "
                mega-mv $path-old/* $path > /dev/null
                
                printf "Done.
                
    Deleting MEGA folder $path-old ... "
                mega-rm -r -f $path-old
                
                read -n 1 -s -r -p "Done.

Once you are finished, immediately go back to PAL-manager
and restart PAL. This operation deletes the old share URL and
a new share URL needs to be generated via re-initialization.

Press any key to return ... "
            fi
            ;;

        # Show explanations of the available options
        [h] ) clear
            read -n 1 -s -r -p "[Separate decryption key from share URL]

    By default, MEGA share URLs come in the format of:
        https://mega.nz/folder/{share uuid}#{decryption key}

    With the decryption key included in the URL, the URL is a
    direct access link. Meaning, a web scraping bot can automatically
    find the URL, access it, and download all of the contents within,
    without human intervention.

    You can add an additional layer of protection against bots by removing
    the decryption key from the URL, and manually post the key some place
    else. By doing so, the link will lead to a MEGA page requesting the
    decryption key in order to gain access, thus requiring human intervention.

    The MEGA share URL would look like this with the decryption key separate:
        https://mega.nz/folder/{share uuid}

    Then all you have to do is include the {decryption key} in, for example,
    a Discord post right above PAL's assigned webhook bot post.

    By enabling this setting, PAL's registered instances will no longer
    include the {decryption key} in its webhook bot posts. You will be
    responsible for making sure your legitimate customers have easy
    access to it.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[Add a random (-15 ≤ x ≤ +15) minute offset to all instance wait periods]

    In theory, it is possible for someone to figure out how long you
    set your PAL instances to wait before refreshing the share URL, as
    the wait time you specified is a fixed number. Once someone figures
    it out, it is possible they could sync up their web scraping bot
    with your instance's refresh period, dampening your security efforts.

    This can easily be fixed by incorporating a random offset that either
    increases or decreases the final time your instances wait before looping.
    By enabling this setting, a random number (0-900) is chosen, and is either
    added on to or subtracted from the final wait time. This results in a
    random (-15 ≤ x ≤ +15) minute offset which randomly changes every time
    an instance loops, and is different for each running instance.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[Change the decryption key for an instance's folder]

    When you create/upload a new file/folder, MEGA generates a unique
    decryption key to be used by anyone who wants to access it. If you
    were wanting MEGA to generate a new decryption key, you would need
    to delete the file/folder, and re-creating/upload it.

    If you wanted to change the decryption key for one of the folders
    assigned to one of your PAL instances, you could do so in a very
    easy way via the following method:

        1.) Rename the current folder to {original name}-old.
        2.) Create a new folder with the {original name}.
        3.) Move all the files from within the old folder into the new folder.
        4.) Delete the old folder.

    By doing this, your instance managed share URLs will now have a new 
    {decryption key} in its URL. If you have enabled the \"Separate 
    decryption key from share URL\" setting, be sure to update your
    post that has the key with the new key, otherwise your customers
    will complain about not having access.

    Note: Realistically, the way PAL operates renders this function not
    all that useful. However, if you did manage to catch and ban someone
    who was leaking your URLs, it wouldn't hurt to refresh the decryption
    key as it more than likely is floating around in public.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Press any key when you're finished reading ... "
            ;;

        # Go back to the manager
        ["q"] ) exit 0
            ;;
        
        # Ignore any other input
        * ) 
            ;;
    esac
done