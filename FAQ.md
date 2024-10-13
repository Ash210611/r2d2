#FAQ

##Create Environment from Scratch

1) Create and Distribute Keypairs

2) (IF PROD) Authenticate with MFA

3) Run the Colorless Architecture Task lists (the shell scripts in ansible/shell, must be tasks=colorlesshomebase.yaml)

4) Run the Colored Architecture Tasks Lists (the ansible shell scripts, task=ColorStack.yaml)

5) Install the Master Lambda Rotator

6) Set up the logging server

7) Build Image

8) Update Image in Fleet

9) Test Image in Fleet

##Update Proxies

1) Run the Utilities/ImageIDScraper.py

2) Update EnvMapping with the updated image ids

3) Re-run the colored architecture scripts (tasks=colorstack.yaml)

4) Test all proxies

##Build Appstream Image

1) Put together deployment package, move it to appstream image builder

2) Unzip package in appstream

3) run deployment.ps1

##Update Appstream Image

1) Shutdown the Fleet

2) Update the Image In Appstream

3) Turn the Fleet back on

##Update Logging Server

1) Run "sudo yum update"

##Rotate IPs

1) Go to Region where you want to rotate IPs, Lambda

2) 'Test' The rotate lambda function. It will actually rotate the ips