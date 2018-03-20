#!/bin/bash

usage() {
  echo "Usage: setup_secrets.sh <options>"
  echo "-p <parameter-store-path>"
  echo "-r <region>"
  echo "-u <dotenv-user>"
  exit
}

while getopts "p:r:u:" opt; do
  case $opt in
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

if [ -z "$PARAMETER_STORE_PATH" ] || [ -z "$REGION" ] || [ -u "$DOTENV_USER" ]; then
  usage
fi

python2.7 /aws_parameter_to_env.py $PARAMETER_STORE_PATH $REGION .env
chown root:$DOTENV_USER .env
chmod 640 .env
