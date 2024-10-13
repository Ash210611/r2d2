#!/bin/bash
export AWS_PROFILE=r2d2nonprodbuildrole

MFA_ARN='arn:aws:iam::776171595951:mfa/jatinder.singh'
ROLE_ARN='arn:aws:iam::776171595951:role/R2D2_BuildRole'

#aws sts get-session-token --serial-number $MFA_ARN --token-code $1 > NULL
aws sts get-session-token --serial-number $MFA_ARN --token-code $1 

#aws sts assume-role --role-arn $ROLE_ARN --role-session-name r2d2-build-access > temp
aws sts assume-role --role-arn $ROLE_ARN --role-session-name r2d2-nonbuildrole-session --profile r2d2nonprodbuildrole > temp

AccessKeyId=$(cat temp | grep AccessKeyId |cut -d'"' -f 4)
SecretAccessKey=$(cat temp | grep SecretAccessKey |cut -d'"' -f 4)
SessionToken=$(cat temp | grep SessionToken |cut -d'"' -f 4)

export AWS_ACCESS_KEY_ID=$AccessKeyId
export AWS_SECRET_ACCESS_KEY=$SecretAccessKey
export AWS_SESSION_TOKEN=$SessionToken

rm temp

echo $r2d2-nonbuildrole-session
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
echo $AWS_SESSION_TOKEN=



#aws sts assume-role --role-arn arn:aws:iam::123456789012:role/role-name --role-session-name "RoleSession1" --profile IAM-user-name > assume-role-output.txt
