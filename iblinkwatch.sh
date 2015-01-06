#!/bin/bash
#
# This script watches the ib bonded interfaces
# and sends an email notificaiton if the state changes
#

#email address for notifications to be sent
EMAIL="strosahl@jlab.org"
SENDER="set from=$HOSTNAME@jlab.org"

#primary interface 
PRIMARY="ib0"

TIMELIMIT=3

#active string
ACTIVE="Currently Active Slave"
DOWN="down"

#file created to tell script that the error has already been detected
TOUCH="/bin/touch"
TOUCHFILE="/tmp/ibalert"

INFO="/proc/net/bonding/bond0"

#information on current bond status
CURRENT=`cat $INFO | grep "$ACTIVE"`

INDIVIDUAL_LINKS=`cat $INFO | grep "$DOWN"`

#check to see if the current active link is the defined primary link
#if it is, and the touchfile exists it removes the touchfule sends an
#email notification, and exits
if [[ $CURRENT ==  *"$PRIMARY"* && $INDIVIDUAL_LINKS != *"$DOWN"* ]]
then
	if [[ -f $TOUCHFILE ]]
	then
		#status restored
		/usr/bin/mutt -e "$SENDER" -s "IB link restored on $HOSTNAME" $EMAIL < $INFO
		rm $TOUCHFILE
	fi
	exit	
fi

echo "here"

#If the touch file is older then the time limit we remove it
if [[ -f $TOUCHFILE ]]
then
	find $TOUCHFILE -mmin +$TIMELIMIT -exec rm $TOUCHFILE \;
fi

#checks to see if a notification has already been given in the last 2 hours
if [[ -f $TOUCHFILE ]]
then
	#notificaiton has already been set for the given time period (TIMELIMIT)
	exit
else
	#at this point a notification needs to be sent
	/usr/bin/mutt -e "$SENDER" -s "ALERT IB link status change on $HOSTNAME" $EMAIL < $INFO
	$TOUCH $TOUCHFILE
	exit
fi

