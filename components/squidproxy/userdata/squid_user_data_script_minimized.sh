#!/bin/bash
iptables -A INPUT -i eth0 -s 172.32.0.0/16 -j ACCEPT
yum -y install jq squid
mv /etc/squid/squid.conf /etc/squid/squid.conf.bak
aws s3 cp s3://r2d2-configuration/squid.conf /etc/squid/squid.conf
systemctl start squid
sudo chkconfig --level 3 squid on
wget -O splunkforwarder-7.3.0-657388c7a488-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.0&product=universalforwarder&filename=splunkforwarder-7.3.0-657388c7a488-linux-2.6-x86_64.rpm&wget=true'
yum -y install ./$(ls splunkforwarder*)
aws s3 cp s3://r2d2-configuration/user-seed.conf "/opt/splunkforwarder/etc/system/local/user-seed.conf"
aws s3 cp s3://r2d2-configuration/inputs.conf "/opt/splunkforwarder/etc/system/local/inputs.conf"
aws s3 cp s3://r2d2-configuration/outputs.conf "/opt/splunkforwarder/etc/system/local/outputs.conf"
/opt/splunkforwarder/bin/splunk start --accept-license
/opt/splunkforwarder/bin/splunk enable boot-start
aws s3 cp s3://r2d2-configuration/route53dns.json ./route53dns.json
region=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
privateIp=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.privateIp')
sed -e "s/\${region}/${region}/" -e "s/\${privateIp}/${privateIp}/" route53dns.json > temp.json
aws route53 change-resource-record-sets --hosted-zone-id Z3FPWSYUJG457F --change-batch file://temp.json
