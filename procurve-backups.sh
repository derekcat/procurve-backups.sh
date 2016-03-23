#!/bin/bash 
# Script written by Derek DeMoss for Dark Horse Comics, Inc. 2016
# This script is designed to backup the running-configs of HP ProCurve switches
# The switch must have ip ssh filetransfer configured, and you must have used ssh/scp/sftp
# to connect to the switch before (~/.ssh/known_hosts must have entries for the switches)
# You must also have sshpass installed, despite complaints of the HomeBrew weenies

TODAY=`date +%Y-%m-%d` # YYYY-MM-DD formatted
MANAGERPASS="DEFINITELYWRONGPASSWORD" # Initialized to junk

while getopts 's:t:h' OPTION # Fancy way to handle flags
do
	case $OPTION in
	s)	SWITCHES="`cat $OPTARG`" # Space-delimited list of switch names, from a file
			;;
	t)	TARGETFOLD="$OPTARG" # Folder to save configs to
			;;
	h)	echo "Usage: procurve-backups.sh -s [SWITCHES] -t [TARGET DIRECTORY]"
			echo "This script is designed to backup all scp-capable HP ProCurve"
			echo "Switches' running-config."
			echo "	-s [SWITCHES]			Text file of a space-delimited list of switches"
			echo "	-t [TARGET DIRECTORY]		Destination Directory for configs"
			echo "	-h				Display this help text"
			exit 3
			;;
	esac
done

echo "Please enter the Manager user's password for the given switches:"
read -s MANAGERPASS # Reads the pass from STDIN

for ASWITCH in $SWITCHES; # Iterate through the list of switches, and copy the running-config
do
	echo "Now backing up $ASWITCH"
	/usr/local/bin/sshpass -p "$MANAGERPASS" scp -q manager@$ASWITCH:/cfg/running-config $TARGETFOLD/$ASWITCH-$TODAY.txt
done

MANAGERPASS="DEFINITELYWRONGPASSWORD" # Reinitialized to junk

echo "Switch backups complete!"
