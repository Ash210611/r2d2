import boto3

def getRegions():
    ec2 = boto3.client('ec2')
    response = ec2.describe_regions()
    regions = response['Regions']
    return regions

    
    