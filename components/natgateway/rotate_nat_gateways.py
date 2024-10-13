#Rotate NAT Gateways
#
# This is a lambda function to rotate NAT Gateways
# given a route table, a regex to search NAT Gateways,
# and the subnet to place the new NAT Gateway in.
# These are provided by env variables.
# This is to change the public facing IPs of
# anything in the VPC making external requests.



import json
import boto3
import os
from datetime import datetime
from datetime import date
from datetime import timedelta
import random
import time

#Global Vars
retry_interval_seconds = 15

#boto objects
ec2 = boto3.resource('ec2')
client = boto3.client('ec2')
cloudwatch_events = boto3.client('events')

def lambda_handler(event, context):

    # Read Env Variables
    route_table_name = os.environ['route_table'] # Name of the Route Table
    nat_regex = os.environ['nat_regex'] #Regex to find the old NAT Gateway
    subnet_id = os.environ['subnet_id'] #subnet ID of new gateway

    # Rotate NAT Gateways
    new_nat_name = GenerateNewNatGatewayName(nat_regex) #Generate New NAT Gateway Name
    nat_gateway_old = GetNatGateway(nat_regex) #Get the Old NAT Gateway
    nat_gateway_new = CreateNatGateway(subnet_id, new_nat_name) #Create the New NAT Gateway
    ReRouteTable(route_table_name, nat_gateway_new) #Point the Route Table to the New NAT Gateway
    DeleteGateway(nat_gateway_old) #Delete the Old NAT Gateway
    ReleaseAddressFromGateway(nat_gateway_old) #Release the Elastic IP used by the Old NAT Gateway

    return {
        'statusCode': 200,
        'body': json.dumps('Successful')
    }


# Generates the New NAT Gateway Name
# Name is nat_regex + '_' + date time string
def GenerateNewNatGatewayName(nat_regex):
    now = datetime.now()
    time_str = now.strftime("%m_%d_%Y_%H:%M")
    new_nat_name = nat_regex+"_" +time_str
    return new_nat_name

# Gets the Old NAT Gateway that will be deleted.
# Do this first so regex only catches 1 NAT Gateway
def GetNatGateway(nat_gateway_regex):
    nat_gateway = client.describe_nat_gateways(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                    ("*"+nat_gateway_regex+"*")
                ]
            },
            {
                'Name': 'state',
                'Values': [
                    'available'
                ]
            }
        ]
    )['NatGateways'][0]
    return nat_gateway

# Creates the New NAT Gateway
# First allocates IP to use
# Creates the Gateway
# Assigns the Name tag
# Waits for NAT Gateway to become Available
def CreateNatGateway(subnet_id, nat_gateway_name):
    allocation_id = AllocateAddress()
    response = client.create_nat_gateway(
        AllocationId=allocation_id,
        SubnetId=subnet_id
    )
    new_nat_gateway = response['NatGateway']
    client.create_tags(
        Resources=[
            new_nat_gateway['NatGatewayId']
        ],
        Tags=[
            {
                'Key': 'Name',
                'Value': nat_gateway_name
            },
        ]
    )
    WaitForNatToBuild(nat_gateway_name)
    return new_nat_gateway


# Allocates the Elastic IP Needed
def AllocateAddress():
    response = client.allocate_address(
        Domain='vpc'
    )
    allocation_id = response['AllocationId']
    return allocation_id

# Waits for NAT Gateway to become Available
def WaitForNatToBuild(nat_name):
    while True:
        nat_gateway_temp = client.describe_nat_gateways(
            Filters=[
                {
                    'Name': 'tag:Name',
                    'Values': [
                        nat_name
                    ]
                }
            ]
            )['NatGateways'][0]
        if nat_gateway_temp['State'] == 'available':
            break
        time.sleep(retry_interval_seconds)


# Assigns the 0.0.0.0/0 (All Traffic) Route
# to point to the New NAT Gateway
def ReRouteTable(route_table_name, nat_gateway):
    routes = list(ec2.route_tables.filter(
        Filters = [
            {
                'Name': 'tag:Name',
                'Values': [
                    route_table_name
                ]
            },
        ]
    ))[0].routes
    zero_rout = next(route for route in routes if route.destination_cidr_block[0] == '0')
    zero_rout.replace(NatGatewayId = nat_gateway['NatGatewayId'])


# Deletes the Old NAT Gateway
def DeleteGateway(nat_gateway):
    client.delete_nat_gateway(
        NatGatewayId= nat_gateway['NatGatewayId']
    )
    WaitForGatewayToDelete()

# Waits for the Old NAT Gateway to delete
# (I think) This is needed for releasing the elastic IP
def WaitForGatewayToDelete():
    while True:
        nat_gateway_temp = client.describe_nat_gateways(
            Filters=[
                {
                    'Name': 'state',
                    'Values': [
                        'deleting'
                    ]
                }
            ]
        )['NatGateways']
        if len(nat_gateway_temp)== 0:
            break
        time.sleep(retry_interval_seconds)

# Releases the Elastic IP
def ReleaseAddressFromGateway(nat_gateway):
    client.release_address(
        AllocationId=nat_gateway['NatGatewayAddresses'][0]['AllocationId']
    )
