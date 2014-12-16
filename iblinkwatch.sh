#!/bin/bash
#
# This script watches the ib bonded interfaces
# and sends an email notificaiton if the state changes
#

#email address for notifications to be sent
EMAIL="strosahl@jlab.org"
MUTT='/usr/bin/mutt'

#primary bond
PRIMARY="ib1"

TIMELIMIT=1

#active string
ACTIVE="Currently Active Slave"

#file created to tell script that the error has already been detected
TOUCH="/bin/touch"
TOUCHFILE="ibalert"

INFO="/proc/net/bonding/bond0"

#information on current bond status
CURRENT=`cat /proc/net/bonding/bond0 | grep "$ACTIVE"`

#check to see if the current active link is the defined primary link
#if it is, and the touchfile exists it removes the touchfule sends an
#email notification, and exits
if [[ $CURRENT == *"$PRIMARY"* ]]
then
	if [[ -f $TOUCHFILE ]]
	then
		$MUTT -s "IB link restored to $PRIMARY on $HOSTNAME" $EMAIL < $INFO
		rm $TOUCHFILE
	fi
	exit	
fi

#checks to see if a notification has already been given in the last 2 hours
#if the touch file exists and is over a certain age
if [[ -f $TOUCHFILE ]]
then
	ALERT=`find $TOUCHFILE -mmin +$TIMELIMIT -exec echo "NOTIFIED" \;`
else
	ALERT="NO"
fi

if [[ $ALERT == "NOTIFIED" ]]
then
	echo "notification sent, exiting"
	exit
fi

#at this point a notification needs to be sent
$MUTT -s "ALERT IB link status change on $HOSTNAME" $EMAIL < $INFO

#create touchfile

$TOUCH $TOUCHFILE
