# LoggingServer 

## About
This is the server that logs all activity from appstream, and the proxies. It runs splunk enterprise and a crontab that queries the aws appstream api for session data. 

## How To Use

install the splunk enterprise by downloading the rpm file from s3 then 
sudo yum install splunk -y

Then do /opt/splunk/bin/splunk start to start it.

Go to the web interface hosted by splunk to complete setup. Set the passwords, etc...

### etc_apps_search_local
paste the contents of this folder into /opt/splunk/etc/apps/search local, this will set up the appstream data to read the file.

### Reports
Paste the reports into the dashboards section of splunk (dashboards -> new dashboard -> edit source -> paste it in)

### cron
setup crontab -e to be like the cron file (so that crontab -L matches the cron file). You need to be sudo user to do so (sudo su). put the getappstreamsessions.sh in /opt/. make sure to configure that file correctly with the number of fleets

## How it works


## NOTES:

Two snapshots of old logging servers:
snap-060350b4c7f5e619e
snap-09dfc41e1439d888f

1 efs
efs-logging-OLD

## TO DO

To Do List:

-
admin
R2D2isH@t