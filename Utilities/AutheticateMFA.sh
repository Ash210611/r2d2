#!/bin/bash

export AWS_PROFILE=${AWS_PROFILE:-""}
MFA_ARN_NAME=${MFA_ARN_NAME:-""}
TOKEN=""
Help()
{
   # Display Help
   echo "This looks for expired keys in different namespaces."
   echo
   echo "Syntax: scriptTemplate [-A|m|t]"
   echo "options:"
   echo "A     AWS profile if not set in export AWS_PROFILE. prod, nonprod are the two standard profiles that should be set in your AWS profile"
   echo "m     MFA name for profile, or can be set with MFA_ARN export. IE lee.kirkland"
   echo "t     AWS Token which is required to be given to the script"
   echo "h     This menu"
   echo
}

while getopts :hA:m:t: option; do
   case "${option}" in
      A ) 
         export AWS_PROFILE="${OPTARG}"
         ;;
      m ) 
         MFA_ARN_NAME="${OPTARG}"
         ;;
      t ) 
         TOKEN="${OPTARG}"
         ;;
      h ) # display Help
         Help
         exit;;
      \?) # incorrect option
         echo "Error: Invalid option"
         Help
         exit;;
   esac
done


if [ -z "$MFA_ARN_NAME" ] && [ -z "$MFA_ARN" ]
then
   echo "You need to either set MFA_ARN through export or give MFA_ARN_NAME to Script"
   Help
   exit;
fi

if [ -z "$AWS_PROFILE" ]  || [ -z "$TOKEN" ]
then
   echo "Missing nessary number of variables what the script has: AWS_PROFILE=${AWS_PROFILE} TOKEN=${TOKEN}"
   Help
   exit;
fi

export MFA_ARN=${MFA_ARN:-"arn:aws:iam::776171595951:mfa/${MFA_ARN_NAME}"}

aws sts get-session-token --serial-number $MFA_ARN --token-code $TOKEN >  temp

AccessKeyId=$(cat temp | grep AccessKeyId |cut -d'"' -f 4)
SecretAccessKey=$(cat temp | grep SecretAccessKey |cut -d'"' -f 4)
SessionToken=$(cat temp | grep SessionToken |cut -d'"' -f 4)

export AWS_ACCESS_KEY_ID=$AccessKeyId
export AWS_SECRET_ACCESS_KEY=$SecretAccessKey
export AWS_SESSION_TOKEN=$SessionToken

rm temp
