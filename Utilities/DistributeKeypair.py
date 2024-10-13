
import boto3
import base64
import os
import sys
 
# Get the total number of args passed to the demo.py
total = len(sys.argv)
 
# Get the arguments list 
cmdargs = str(sys.argv)

if (total != 2):
    print ("wrong number of arguments supplied: %s" % cmdargs)
    sys.exit()

pubFile=str(sys.argv[1])

def getRegions():
    ec2 = boto3.client('ec2',region_name='us-east-1')
    response = ec2.describe_regions()
    regions = response['Regions']
    regionList = []

    for region in regions:
        regionList.append(region['RegionName'])
    return regionList


regions = getRegions()
publicKey = ''
script_dir = os.path.dirname(__file__)
rel_path = 'keyPairs/' + pubFile
abs_file_path = os.path.join(script_dir, rel_path)

try:
    with open(abs_file_path,'r') as file:
        publicKey = file.read()
except Exception as e:
    print(e)
    print("Make sure to add file to Utilities/keyPairs/, and pass file name to script including extension. Example: 'keypair.pem")
    sys.exit()

for region in regions:
    ec2 = boto3.client('ec2',region_name=region)
    try:
        ec2.import_key_pair(
            KeyName = pubFile.rsplit(".",1)[0],
            PublicKeyMaterial= publicKey
        )
    except Exception as e:
        print(e)