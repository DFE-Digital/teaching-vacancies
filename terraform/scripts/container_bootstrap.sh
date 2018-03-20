#!/bin/bash

usage() {
  echo "Usage: container_bootstrap.sh <options>"
  echo "-b <scripts-bucket-name>"
  echo "-p <parameter-store-path>"
  echo "-r <region>"
  echo "-u <dotenv-user>"
  exit
}

while getopts "b:p:r:u:" opt; do
  case $opt in
    b)
      SCRIPTS_BUCKET_NAME=$OPTARG
      ;;
    p)
      PARAMETER_STORE_PATH=$OPTARG
      ;;
    r)
      REGION=$OPTARG
      ;;
    u)
      DOTENV_USER=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

if [ -z "$SCRIPTS_BUCKET_NAME" ] || [ -z "$PARAMETER_STORE_PATH" ] || [ -z "$REGION" ] || [ -u "$DOTENV_USER" ]; then
  usage
fi

aws s3 cp s3://$SCRIPTS_BUCKET_NAME/setup_secrets.sh /setup_secrets.sh
aws s3 cp s3://$SCRIPTS_BUCKET_NAME/aws_parameter_to_env.py /aws_parameter_to_env.py

chmod +x /setup_secrets.sh
/setup_secrets.sh -p $PARAMETER_STORE_PATH -r $REGION

rm /setup_secrets.sh
rm /aws_parameter_to_env.py
