# Utilities 

## About

## How To Use

### AuthenticateMFA
Call this shell file and pass in a MFA code to authenticate the AWS CLI
source ./AuthenticateMFA.sh 123456

### ClearMFA
Call this in order to clear all authentication variables (necessary to re-auth)
source ./ClearMFA.sh

### DistributeKeypair
This distributes a keypair across all regions. This doesn't support any command line parameters, source must be edited to reference the new keypair. 

### ImageIDScraper
Returns the image id for each region of the CIS AWS Linux Level 1 image. This mapping can then be directly put into the envmapping file in ansible/vars

## How it works

## TO DO

To Do List:

-
