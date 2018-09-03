# Google-Home-Notifier-Launcher
###Launcher/Monitor for Harper Reed's Python Google Home Notifier

This is launcher for Harper Reed's Google Home Notifier Listener - https://github.com/harperreed/google-home-notifier-python
It is an attempt to keep the notifier working -the listener tends to err out if you are casteing to a Group apparently due to the 
pychomecast library's inability to keep track of google groups changing ips (see this: https://github.com/home-assistant/home-assistant/issues/9800). Harper's "main.py" script has been renamed gnotify.py for purposes of this script.

###Features:
 - relaunches the notifier if it dies
 - restarts it if it errs and is no longer connected
 
 ###After downloading it:
 ```bash
 sudo chown root gnotify-launch.sh
 sudo crontab -e
 #Add to your crontab: 
 @reboot [path to your script]/gnotify-launch.sh
 
```
