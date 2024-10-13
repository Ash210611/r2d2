#!/bin/bash
# ***** for use in Prod setup *****
stack='R2D2_User'
fleet='r2d2_prod_user_fleet'
region='us-east-1'
aws appstream describe-sessions --stack $stack --fleet-name $fleet --region $region --query "Sessions[*].[ConnectionState,AuthenticationType,UserId,FleetName,StackName,State,StartTime,MaxExpirationTime,NetworkAccessConfiguration.EniId,NetworkAccessConfiguration.EniPrivateIpAddress,Id]" --output text | sed "s/^/$(date +%s.%3N)\t/" >> /var/log/appstream.log 2>&1

stack='R2D2_smprofile'
fleet='r2d2fleet_prodfic_virginia_blue'
region='us-east-1'
aws appstream describe-sessions --stack $stack --fleet-name $fleet --region $region --query "Sessions[*].[ConnectionState,AuthenticationType,UserId,FleetName,StackName,State,StartTime,MaxExpirationTime,NetworkAccessConfiguration.EniId,NetworkAccessConfiguration.EniPrivateIpAddress,Id]" --output text | sed "s/^/$(date +%s.%3N)\t/" >> /var/log/appstream.log 2>&1

# **********************************

#!/bin/bash
# ***** for use in nonProd setup *****
stack='R2D2_User_nonProd'
fleet='r2d2_user_nonprod_fleet'
region='us-east-1'
aws appstream describe-sessions --stack $stack --fleet-name $fleet --region $region --query "Sessions[*].[ConnectionState,AuthenticationType,UserId,FleetName,StackName,State,StartTime,MaxExpirationTime,NetworkAccessConfiguration.EniId,NetworkAccessConfiguration.EniPrivateIpAddress,Id]" --output text | sed "s/^/$(date +%s.%3N)\t/" >> /var/log/appstream.log 2>&1

stack='R2D2_smprofile_nonProd'
fleet='r2d2_smprofile_nonprod_fleet'
region='us-east-1'
aws appstream describe-sessions --stack $stack --fleet-name $fleet --region $region --query "Sessions[*].[ConnectionState,AuthenticationType,UserId,FleetName,StackName,State,StartTime,MaxExpirationTime,NetworkAccessConfiguration.EniId,NetworkAccessConfiguration.EniPrivateIpAddress,Id]" --output text | sed "s/^/$(date +%s.%3N)\t/" >> /var/log/appstream.log 2>&1
