#!/bin/bash
#
# This script watches the ib bonded interfaces
# and sends an email notificaiton if the state changes
#

#email address for notifications to be sent
EMAIL="strosahl@jlab.org"
MUTT='/usr/bin/mutt'

#primary interface 
PRIMARY="ib1"

TIMELIMIT=3

#active string
ACTIVE="Currently Active Slave"

#file created to tell script that the error has already been detected
TOUCH="/bin/touch"
TOUCHFILE="ibalert"

INFO="/proc/net/bonding/bond0"

#information on current bond status
CURRENT=`cat $INFO | grep "$ACTIVE"`

#check to see if the current active link is the defined primary link
#if it is, and the touchfile exists it removes the touchfule sends an
#email notification, and exits
if [[ $CURRENT == *"$PRIMARY"* ]]
then
	if [[ -f $TOUCHFILE ]]
	then
		#status restored
		$MUTT -s "IB link restored to $PRIMARY on $HOSTNAME" $EMAIL < $INFO
		rm $TOUCHFILE
	fi
	exit	
fi

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
	$MUTT -s "ALERT IB link status change on $HOSTNAME" $EMAIL < $INFO
	$TOUCH $TOUCHFILE
	exit
fi

