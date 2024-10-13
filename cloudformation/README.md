# Cloudformation 

## About
Contains the cloudformation scripts to build the environments. 

## How To Use
The Cloudformation scripts are used by ansible to build the environment. No direct use is 


## How it works

### EgressBridgeCFN
Bridges the connection between the homebase vpc and the egress vpc. Specifically, sets up the route from the vpc to the egress, since route tables need to be bi-directional. 

### EgressRegionCFN
Sets up the egress region. The proxy server, NAT gateway, vpc, subnets, internet gateway, route tables, and vpc peering connection back to homebase. 

### HomebaseColorlessInfrastructureCFN
Sets up colorless infrastructure, like the homebase vpc, logging servers, route tables, image builders and jumpbox

### HomebaseR2D2StackCFN
Sets up the homebase infrastructure that is colored, such as the fleets. 


## TO DO

To Do List:

- Split non-updatable resources into seperate scripts, so that we don't run into issues when trying to update. 
- because of the envmapping, we may be able to get rid of the envmapping part in the cfn
