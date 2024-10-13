# NatGatewayRotator 

## About
This is the python code set up in the lambdas to rotate the nat gateways in each region. This consists of a master scheduler, and a lambda in each region that does the actual rotation. 

## How To Use
Ansible and cloudformation should deploy the lambdas. To manually rotate a region, find the lambda in that region, and run a test case with any data. 

## How it works
Python makes a new EIP, new Natgateway. Re-routes traffic on routetable to new gateway. deletes old gateway and EIP

## TO DO

To Do List:

-
