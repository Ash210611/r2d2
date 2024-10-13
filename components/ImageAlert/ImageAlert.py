import json
import boto3


productID = '*4c096026-c6b0-440c-bd2f-6d34904e4fc6*'
topicARN = 'arn:aws:sns:us-east-1:776171595951:ImageAlerts'




def GetRegions():
    ec2 = boto3.client('ec2')
    response = ec2.describe_regions()
    regions = response['Regions']

    regionList = []

    for region in regions:
        regionList.append(region['RegionName'])
    return regionList


def GetLatestImage(region, productID):
    ec2 = boto3.resource('ec2',region_name=region)
    images = list(ec2.images.filter(Filters=[
        {
            'Name': 'name',
            'Values': [productID]
        }
    ]))
    images.sort(key=lambda x: x.creation_date,reverse=True)
    return images[0]


def GetNewestRegionDict(regionList):
    regionDict = {}
    for region in regionList:
        image = GetLatestImage(region, productID)
        regionDict[region]= image.image_id
    return regionDict


def GetRegionsProxyInstanceImageId(regionName):
    ec2 = boto3.resource('ec2',region_name=regionName)
    filters = [{'Name':'tag:Name', 'Values':['*proxy*']}]
    instances = list(ec2.instances.filter(Filters=filters))
    if len(instances) == 0:
        return None
    return instances[0].image_id


def FinalListOfImages(newestImages):
    message = "This is the newest configuration of images:\n"
    for region in newestImages:
        message += region +": " +newestImages[region]+'\n'
    print(message)




def AlertUsThatImagesChanged(updateList,newestImages):
    message = "The following regions have out of date proxies:\n"
    message += str(updateList)
    message += "\n"
    message += "This is the newest configuration of images:\n"
    for region in newestImages:
        message += region +": " +newestImages[region]+'\n'
    print(message)


def SendSNSMessage():
    message = "Something is out of date, please check lambda logs"
    client = boto3.client('sns')
    client.publish(
        TargetArn=topicARN,
        Message=message
    )


def CheckIfImagesChanged(sendEmail):
    regions = GetRegions()
    newestImages = GetNewestRegionDict(regions)
    updateList = []
    for region in regions:
        currentImageId = GetRegionsProxyInstanceImageId(region)
        newestImageId = newestImages[region]
        if currentImageId == None:
            continue


        if currentImageId != newestImageId:
            updateList.append(region)
            print(region+": "+ currentImageId +" -> " +newestImageId)
            continue
        print(region+": "+ currentImageId +" == " +newestImageId)


    if len(updateList) != 0:
        AlertUsThatImagesChanged(updateList, newestImages)
        if sendEmail == True:
            SendSNSMessage()
    else:
        FinalListOfImages(newestImages)
    print("lambda done")


def lambda_handler(event, context):
    if "Email" in event and event['Email'] == "False":
        CheckIfImagesChanged(False)
    else:
        CheckIfImagesChanged(True)
    return 0

if __name__ == '__main__':
    CheckIfImagesChanged(False)


