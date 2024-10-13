#!/bin/bash

# Download Splunk server - Linux

URL="https://www.splunk.com/en_us/download/splunk-enterprise.html"
OS_REGEX="linux-2\.6-x86_64\.rpm"
RESPONSE=`curl -s --connect-timeout 10 --max-time 10 $URL`
LINK=`echo $RESPONSE | egrep -o "data-link=\"https://[^\"]+-${OS_REGEX}\"" | cut -c12- | rev | cut -c2- | rev`
echo $RESPONSE $LINK

# Download Splunk forwarder - Linux rpm version
#URL="https://www.splunk.com/en_us/download/universal-forwarder.html"
#OS_REGEX="linux-2\.6-x86_64\.rpm"
#RESPONSE=`curl -s --connect-timeout 10 --max-time 10 $URL`
#LINK=`echo $RESPONSE | egrep -o "data-link=\"https://[^\"]+-${OS_REGEX}\"" `
#echo $LINK

# Download Splunk forwarder - Windows msi version
#URL="https://www.splunk.com/en_us/download/universal-forwarder.html"
##echo $RESPONSE | grep msi

#OS_REGEX="-x64-release\.msi"
#OS_REGEX="Linux-x86_64\.md5"

#RESPONSE=`curl -s --connect-timeout 10 --max-time 10 $URL`

#echo $RESPONSE | grep msi

#LINK=`echo $RESPONSE | egrep -o "data-link=\"https://[^\"]+-${OS_REGEX}\"" `

#echo $LINK

#LINK=`echo $RESPONSE | egrep -o "data-link=\"https://[^\"]+-${OS_REGEX}\"" | cut -c12- | rev | cut -c2- | rev`


#wget --no-check-certificate -P /tmp $LINK

#exit 0
