#!/usr/bin/env bash

set -eu

NAMESPACE=$(jq -r '.namespace' terraform/workspace-variables/${CONFIG}.tfvars.json)

### Deploy maintenance app ###
echo Update image tag in the maintenance deployment manifest
perl -p -e "s/#MAINTENANCE_IMAGE_TAG#/${MAINTENANCE_IMAGE_TAG}/" maintenance_page/manifests/maintenance/deployment_maintenance.yml.tmpl \
    > maintenance_page/manifests/maintenance/deployment_maintenance.yml

echo Create maintenance deployment
kubectl apply -n ${NAMESPACE} -f maintenance_page/manifests/maintenance/deployment_maintenance.yml

echo Create maintenance service
kubectl apply -n ${NAMESPACE} -f maintenance_page/manifests/maintenance/service_maintenance.yml

echo Create maintenance ingress
kubectl apply -n ${NAMESPACE} -f maintenance_page/manifests/${CONFIG}/ingress_maintenance.yml

### Change ingress ###
# Remove if the service does not declare the external ingress i.e. null_host_header = false
# https://github.com/DFE-Digital/terraform-modules/blob/101f2fa721661cbf0ad05e8105c3628900351008/domains/environment_domains/variables.tf#L15
echo Configure external ingress to point at the maintenance app
kubectl apply -n ${NAMESPACE} -f maintenance_page/manifests/${CONFIG}/ingress_external_to_maintenance.yml

echo Configure internal ingress to point at the maintenance app
kubectl apply -n ${NAMESPACE} -f maintenance_page/manifests/${CONFIG}/ingress_internal_to_maintenance.yml

echo Create temp ingress
kubectl apply -n ${NAMESPACE} -f maintenance_page/manifests/${CONFIG}/ingress_temp_to_main.yml

# Retrieve the teacherservices.cloud internal domain from the temp ingress manifest
TEMP_URL=$(awk '/name:.*cloud/ {print $2}' ./maintenance_page/manifests/${CONFIG}/ingress_temp_to_main.yml)

echo
echo Maintenance page enabled at main URL
echo Application available for testing at https://${TEMP_URL}
