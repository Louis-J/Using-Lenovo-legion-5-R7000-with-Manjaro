#!/bin/bash

################################################################################
# Author:			Alessio 'Slux' Di Fazio <slux83@gmail.com>
# Author-website:	http://www.capponcino.it/alessio
# License:			GPL-v3
# Version:			1.1
################################################################################

# dcop yakuake
# 
# yakuake is runnnig?
# if [ $? != "0" ]; then
# 	kdialog --error "Yakuake is not running! Run it before."
# 	exit 1
# fi



# if `! dcop yakuake >/dev/null 2>/dev/null`; then
# 	yakuakeStarted=true
# 	yakuake
# fi
# 

#open a new session
# dcop yakuake DCOPInterface slotAddSession
# qdbus org.kde.yakuake /yakuake/sessions addSession  > /dev/null
sess_id=`qdbus org.kde.yakuake /yakuake/sessions addSession`

#get the id of the new session
# sess_id=`dcop yakuake DCOPInterface selectedSession`

#build command
if [ "$1" != "" ]; then
	command="cd ""'"$1"'"
else
	PWD=`pwd`
	command="cd ""'"$PWD"'"
fi

#run commands
# dcop yakuake DCOPInterface slotRunCommandInSession $sess_id "$command"
# dcop yakuake DCOPInterface slotRunCommandInSession $sess_id "clear"
qdbus org.kde.yakuake /yakuake/sessions runCommand "$command" > /dev/null
qdbus org.kde.yakuake /yakuake/sessions runCommand "clear" > /dev/null

#show the terminal
# dcop yakuake DCOPInterface slotToggleState
qdbus org.kde.yakuake /yakuake/window toggleWindowState  > /dev/null


