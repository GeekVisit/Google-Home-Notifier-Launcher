#!/bin/bash
# Google Home Notifier Launcher
# This is launcher for Harper Reed's Google Home Notifier - https://github.com/harperreed/google-home-notifier-python
# It is an attempt to keep the notifier working - the script tends to error out if you use Groups due to the pychomecast library's inability to 
# keep track of google groups. Harper's "main.py" script has been renamed gnotify.py for purposes of this script.
#see this: https://github.com/home-assistant/home-assistant/issues/9800
# Features:
# - relaunches the notifier if it dies
# - restarts it if it errs and is no longer connected 
#
#MIT LICENSE: 
#Copyright 2018 Thinktier, LLC 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#This script is intended to restart google notifier if it errors out
#main reason it errors out apparently is that if you try to cast to a group
#pychromecast library can't handle it as google group schange their ip as discovered with netdisco
#see this: https://github.com/home-assistant/home-assistant/issues/9800
#the library hasn't been revised to fix the issue so this just restarts
#gnotify.py
#script also will restart gnotify if it dies for some reason

#To follow logfile use this command: tail --follow=name /tmp/gnotify.log --retry

LOGFILE=/tmp/gnotify.log
#Rename Harper's main.py to gnotify.py and poin this to it https://github.com/harperreed/google-home-notifier
GNOTIFY="~/google-home-notifier-python/gnotify.py"
SCRIPT_NAME=$(basename $0)
VERSION=0.2
echo -e "\r\nGoogle Home Notifier Launcher"
echo -e "Version: $VERSION" 

#make sure only once instance runs at same time

if pidof -o %PPID -x $SCRIPT_NAME > /dev/null 2>&1 ; then
	echo -e "$SCRIPT_NAME is already running, exiting ... \r\n" | tee $LOGFILE
	exit
fi

echo -e "Starting  Google Home Notifier - Listens for Chromecasts from pi..."
echo -e "Log file is located at /tmp/gnotify.log"
rm -f $LOGFILE > /dev/null 2>&1

#killall gnotifiers if exist
killall -r gnotify.py > /dev/null 2>&1

#########################################################
# Main Loop
#########################################################
while : 
do

#########################################################
while : 
do

#########################################################
# Tests for multiple instances, errors, etc and if so restarts
#########################################################
#restart gnotify if not currently running or it dies for some reason

	if ! \ps -a | grep "gnotify.py" -m 1 > /dev/null ; then
	touch $LOGFILE
	echo -e "\r\ngnotify.py is not running - launching ..." | tee $LOGFILE
	sleep 1
	$GNOTIFY  2>> $LOGFILE & 
	echo -e "Now monitoring Google Notifier ..." | tee $LOGFILE
	fi	
	sleep 1

#########################################################
	#detect if Not Connected Error
	if  grep "pychromecast.error.NotConnected" $LOGFILE ; then

		ERROR= $(grep "pychromecast.error.NotConnected" $LOGFILE )
		killall -r gnotify.py
		sleep 1	
 		rm -f $LOGFILE 
		echo -e "\r\n##ERROR: Google Notifier Lost Connection - $ERROR \r\nRestarting "$(date) | tee $LOGFILE 
		break ;
	fi
##########################################################
# Restart if trace back error

	if  grep "Traceback" $LOGFILE ; then
		killall -r gnotify.py
		sleep 1	
		rm -f $LOGFILE 
		echo -e "\r\nDetected Error - Restarting "$(date) | tee $LOGFILE 
		break ;
	fi
##########################################################
#detect too large a file
	if [[ $(find $LOGFILE -type f -size +100k 2>/dev/null) ]]; then
		killall -r gnotify.py
		sleep 1	
    		rm -f $LOGFILE	
		echo -e "\r\nRestarting File too Large $(date)" | tee $LOGFILE 
		break ;
	fi
done
done
