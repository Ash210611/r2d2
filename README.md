# r2d2
## Remote Retrievable Disposable Desktop

### O&M Checklist

- [ ] Disk Space okay on Proxies
- [ ] Proxy Logs are updating in Splunk
- [ ] Splunk License is not being exceeded
- [ ] AppStream Logs are in Splunk (user sessions)
- [ ] Session logs in Splunk (NICE DCV Logs from instances)
- [ ] HTTP Logging in Splunk
- [ ] Exit Nodes are set properly in each image
- [ ] Splunk Disk Space is okay
- [ ] Jump box is stopped
- [ ] Jump Box SG is empty

### AWS AppStream 2.0 based Architecture
BaaS (Browser as a Service) based solution. AppStream is an AWS service that streams applications. Using AppStream, USCIS can customize browsers (e.g. proxy settings, Add-Ons, etc.) and deliver them securely through a web based streaming service.

![AppStream High-level Architecture](resources/R2D2%20Architecture%20v2.0.png)



### Authentic8 Silo + Toolbox
BaaS (Browser as a Service) based solution. Silo and Toolbox are virtual browsers provided by the company Authentic8. Silo provides basic browsing in an isolated environment. Toolbox provides additional capabilities including a choice of geolocated egress points and attribution management. 





### AWS WorkSpaces based Architecture
DaaS (Desktop as a Service) solution based on AWS Workspaces service.


###
- Install Chrome
- Install Splunk - splunk admin password - download from splunk site
- Update Firefox
- Install Chrome group policy
- create image 
    - chrome icon location - %ProgramFiles%\Google\Chrome\Application\chrome.exe
- Clean Splunk config
    - "C:\Program Files\SplunkUniversalForwarder\bin\splunk.exe" clone-prep-clear-config

File Locations:
bookmarks.json - in chrome GPO
chrome gpo file locations - 
- Adm - c:\windows\system32\grouppolicy\Adm\chrome.adm
- Machine - Registry.pol  - c:\windows\system32\grouppolicy\machine\registry.pol
chrome.bat - c:\users\public



mozilla.cfg - c:prog86\mozilla firefox
local-settings.js - c:prog86\mozillafirefox\defaults\pref

.xpi - firefox extensions - c:\prog86\firefox\browser\extensions


Splunk Configuration
c:\prog\splunk\etc\apps\splunktawindows\local\inputs.conf

Splunk Server cron: to pull appstream logins


[tcpout:default-autolb-group]
server = 172.31.1.96:9997

[tcpout-server://172.31.1.96:9997]

172.31.0.0/16 - N. Virginia - Appstream - vpc-f94fc582
172.32.0.0/16 - Oregon - Proxy - vpc-65eb901c
172.33.0.0/16 - Frankfurt - Proxy - vpc-480e8123
172.34.0.0/16 - Sao Paulo - Proxy - vpc-2a8c264d
172.35.0.0/16 - N. Virginia - Jump - vpc-3363e948
172.36.0.0/16 - Ohio - Proxy - vpc-
172.39.0.0/16 - N. Virginia - HAGReplacement - vpc-e5977f9f

Oregon Proxy - FDNS: 172.32.0.11:3128
Sao Paulo Proxy - FDNS: 172.34.0.30:3128
Frankfurt Proxy - FDNS: 172.33.0.9:3128
Ohio Proxy - Field FDNS: 172.36.0.6:3128

1. Delete default VPCs
2. Add VPCs
3. Peer VPCs
4. Create 1 /26 subnet in each proxy location
5. Create NAT Gateways in proxy locations
6. Create jump VPC and subnet
7. Create jump internet gateway
8. Update route tables to include nat gateways and peered connection
9. create (2) /25 for Appstream fleet and (1) /26 for image builder 
10. Enable Flow Logs at VPC level
11. Update network ACLs on proxy subnets to only allow port 3128 from AppStream subnets and 22 from Jump subnet
12. update hostnames - vi /etc/hostname
13. update lookups - vi /etc/hosts

Nat Gateways (3) - + 1TB in and out = ~$500/month
EC2 Oregon - ~$300/month
EC2 Brazil - ~$500/month
EC2 Germany - ~$400/month
AppStream - 50 Instances VA Region - (50 users * $4.19 User RDS SAL Fee =  $209.50) + instance Fees:  50 instances @ 16 hours/day (~$3000) = $3209.50
——————————————
Total: ~$4900/month for 50 users
