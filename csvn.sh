#!/bin/sh

#This is a little diddy I made to make a backup of all the subversion repos.  I found a limitation
#in svnadmin hotcopy that you cannot simply all your repos.  So this will do that for you and
#maintain 1 rotation.  Its nothing fancy shmancy.  Enjoy

#Written by Ian Langdon ianlangdon.ca for Trapeze Media trapeze.com

#Version History
#Version 1.0
#Version 1.1 - Added rotated log support
#Version 1.2 - Added a mount point check to fail scr script of backup local is not a mounted file system,

#Vairables are good!  :)

SUBVERSION_PATH=/srv/Subversion		#Where do the live Subversion repos live?
BACKUP_MOUNT=/backups			#The Mount point of the backup to test before running.
BACKUP_DEST=/backups/SubVersionHotCopy		#Where are we putting the fresh hot copy
LOG=/var/log/subversionhotcopy		#Where are we going to put the progress log?

#Here is the pretty in screen header
HEADER="Trapeze Subversion HotCopy Script"
LINE="<*><*><*><*><*><*><*><*><*><*><*><*><*><*><*><*><*><*><*>"


#When test mode is NOT 0, you can futz with this script w/o and "action".  
#THIS NEEDS TO BE 0 OR THIS WILL NOT DO ANYTHING OTHER THAN GO THROUGH THE MOTIONS.
TESTMODE=0

#___[ This is the hood, nothing need be changed here unless you are tinkering ]___________________

# This section will test to see if the destination is a mount point or fail.
# Otherwise this may fill the root file system in our environment.
if grep -q "^[^ ]* ${BACKUP_MOUNT} " /etc/mtab; then
	echo "Mount point is good!"
else
	echo "FAIL!  Location is not a mount point"
	exit 2
fi


#Show the pretty header.
clear
echo "$HEADER" ; echo "$LINE"
echo "Removing $BACKUP_DEST.old, please wait..."


#Remove the .old backup/log
echo "Rotating backup, please wait..."
if [ "$TESTMODE" -eq '0' ] ; then rm -R -f $BACKUP_DEST.old ; fi
if [ "$TESTMODE" -eq '0' ] ; then rm -R -f $LOG.old ; fi

#Rotate the last backup/log to .old
if [ "$TESTMODE" -eq '0' ] ; then mv $BACKUP_DEST $BACKUP_DEST.old ; fi
if [ "$TESTMODE" -eq '0' ] ; then mv $LOG $LOG.old ; fi

#Create the new folder for the fresh backup
if [ "$TESTMODE" -eq '0' ] ; then mkdir $BACKUP_DEST ; fi


#Lets now create a list of all the repos 
#     There may be a cleaner way to do this, but it works.
/bin/ls -1 $SUBVERSION_PATH >list

#For sh-ts and giggles, lets see how many repos
LINES=`wc -l list`
echo "We have $LINES repos."

# Init the count
COUNT=0

#Lets step through our newly created file here.
while IFS= read -r file
do
	#Show the pretty header
	clear
	echo "$HEADER" ; echo "$LINE"

	#If not in test mode, make a log entry.
	if [ "$TESTMODE" -eq '0' ] ; then echo "`date +%y%m%d`: HotCopy repo $file" >>$LOG ; fi 

	#Tell the user whats happening...
	echo "Working in repo: $file"
	echo "Repo $COUNT of $LINES"

	#Create a folder for the hot copy of the repo
	if [ "$TESTMODE" -eq '0' ] ; then mkdir $BACKUP_DEST/$file ; fi

	#The meat and potatos, HOT COPY!
	if [ "$TESTMODE" -eq '0' ] ; then /usr/bin/svnadmin hotcopy $SUBVERSION_PATH/$file $BACKUP_DEST/$file/. ; fi

	#What good is a loop if we cont advance the count!
	COUNT=`expr $COUNT + 1`
	
	#This is simply for test mode visuals.  If in test mode, wait for a bit.
	if [ "$TESTMODE" -eq '1' ] ; then sleep .2 ; fi

done <"list"

#Clean up the list of repos we made earlier.
rm  -f list

