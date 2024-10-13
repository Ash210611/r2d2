import boto3
import json
import pprint

client = boto3.client('appstream')
imageNameFilter = "AppStream-WinServer2019"
topicARN = 'arn:aws:sns:us-east-1:776171595951:ImageAlerts'

def main(sendEmail):
    publicImages = GetPublicImages()

    mostResentImage = GetMostResentImage(publicImages)

    fleets = GetFleets()
    fleetImageNames= [fleet['ImageName'] for fleet in fleets]
    fleetImages = GetImagesByName(fleetImageNames)

    outOfDateImages = GetOutOfDateImages(mostResentImage,fleetImages)

    outOfDateFleets = GetOutOfDateFleets(fleets,outOfDateImages)
    JsonPrettyPrint(outOfDateFleets)
    if len(outOfDateFleets)!= 0:
        AlertOutOfDate(mostResentImage)
        if sendEmail == True:
            SendSNSMessage()
            
def AlertOutOfDate(mostResentImage):
    message = "The most resent Appstream image is:\n"
    message+= mostResentImage['Name']
    print(message)


def SendSNSMessage():
    message = "Something is out of date, please check lambda logs"
    client = boto3.client('sns')
    client.publish(
        TargetArn=topicARN,
        Message=message
    )


def GetOutOfDateFleets(fleets,outOfDateImages):
    outOfDateFleetNames = [fleet['Name'] for fleet in fleets if fleet['ImageName'] in outOfDateImages]
    return outOfDateFleetNames


def ExtractImageNameAndBaseDate(images):
    toRet = [(image['Name'],image['PublicBaseImageReleasedDate']) for image in images]
    return toRet


def GetOutOfDateImages(mostResentImage,fleetImages):
    formattedImages = ExtractImageNameAndBaseDate(fleetImages)
    baseImageDate = mostResentImage['PublicBaseImageReleasedDate']
    outOfDateImages = [image[0] for image in formattedImages if image[1]!= baseImageDate]
    return outOfDateImages





def GetPublicImages():
    response =  client.describe_images(Type='PUBLIC')
    images = response['Images']

    while 'NextToken' in response:
        response = client.describe_images(Type='PUBLIC',NextToken=response['NextToken'])
        images+= response['Images']

    return images

def GetFleets():
    response = client.describe_fleets()
    fleets = response['Fleets']
    return fleets

def GetImagesByName(imageNames):
    response = client.describe_images(Names=imageNames,MaxResults=25)
    images = response['Images']
    return images

def GetMostResentImage(images):
    filteredImages = FitlerImages(images)
    sortedImages = sorted(filteredImages,key=lambda x: x['PublicBaseImageReleasedDate'],reverse=True)
    return sortedImages[0]

def FitlerImages(images):
    filteredImages = [image for image in images if imageNameFilter in image['Name']]
    return filteredImages

def JsonPrettyPrint(jsonText):
    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(jsonText) 

def lambda_handler(event, context):
    if "Email" in event and event['Email'] == "False":
        main(False)
    else:
        main(True)
    return 0

if __name__ == '__main__':
    main(False)