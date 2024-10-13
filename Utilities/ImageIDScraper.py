import boto3
import os
from datetime import datetime


#os.environ["HTTP_PROXY"] = "proxy.apps.dhs.gov:80"
#os.environ["HTTPS_PROXY"] = "proxy.apps.dhs.gov:80"
productID = '*4c096026-c6b0-440c-bd2f-6d34904e4fc6*'



def getRegions():
    ec2 = boto3.client('ec2')
    response = ec2.describe_regions()
    regions = response['Regions']

    #print(regions)

    regionList = []

    for region in regions:
        regionList.append(region['RegionName'])
    return regionList


def getLatestImage(region, productID):
    ec2 = boto3.resource('ec2',region_name=region)
    images = list(ec2.images.filter(Filters=[
        {
            'Name': 'name',
            'Values': [productID]
        }
    ]))
    images.sort(key=lambda x: x.creation_date,reverse=True)
    return images[0]

regionList = getRegions()
regionDict = {}
for region in regionList:
    image = getLatestImage(region, productID)
    regionDict[region]= image.image_id
    print(region+": "+image.image_id)

for region in regionList:
    image = getLatestImage(region, productID)
    regionDict[region]= image.image_id
    print(region+": ")

print(regionDict)



#print(getLatestImage("eu-south-1",productID))
#print(getLatestImage("ap-northeast-3",productID))
#print(getLatestImage("af-south-1",productID))
