import boto3
import base64
import os
import sys
 
# Get the total number of args passed to the demo.py
total = len(sys.argv)
 
# Get the arguments list 
cmdargs = str(sys.argv)

if (total != 1):
    print ("wrong number of arguments supplied: %s" % cmdargs)
    sys.exit()

session = boto3.Session(profile_name='r2d2prodbuildrole')
ec2 = session.client('ec2')

def getRegions():
    response = ec2.describe_regions()
    regions = response['Regions']
    regionList = []

    for region in regions:
        regionList.append(region['RegionName'])
    regionList.sort()
    return regionList

regions = getRegions()

for region in regions:
    ec2 = boto3.client('ec2',region_name=region)
    response = ec2.describe_key_pairs()['KeyPairs']
    for key in response:
        found_instance = ec2.describe_instances(
            Filters=[
                {
                    'Name': 'key-name',
                    'Values': [key['KeyName']]
                }
            ]
        )['Reservations']
        if len(found_instance) == 0:
            print (region + " -> " + key['KeyName'] + " is not used")
 #       else:
 #           print (region + " -> " + key['KeyName'] + " is used")
       
