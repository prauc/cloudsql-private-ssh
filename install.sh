#!/bin/bash

echo Please enter GCP Location:
read LOCATION
echo Ok, GCP Location set to: $LOCATION

echo Please enter GCP Project ID:
read PROJECT_ID
echo Ok, GCP Project ID set to: $PROJECT_ID

echo Please enter VPC Name:
read VPC
echo Ok, VPC set to: $VPC

echo Please enter VPC Subnet Name:
read VPC_SUBNET
echo Ok, GCP VPC Subnet set to: $VPC_SUBNET

echo Please enter CloudSQL Instance Name:
read CLOUDSQL_INSTANCE
echo Ok, CloudSQL Instance Name set to: $CLOUDSQL_INSTANCE

gcloud compute firewall-rules create ssh-iap \
    --project=$PROJECT_ID \
    --direction=INGRESS \
    --priority=1000 \
    --network=$VPC \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20

NAT_ROUTER=cloudsql-bastion-router

gcloud compute routers create $NAT_ROUTER \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --network=$VPC

gcloud compute routers nats create nat-config \
    --router-region $LOCATION \
    --router $NAT_ROUTER \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

CLOUDSQL_CONNECTION_STRING="$PROJECT_ID:$LOCATION:$CLOUDSQL_INSTANCE"
INSTANCE_NAME=cloudsql-bastion-host

gcloud compute instances create $INSTANCE_NAME \
    --machine-type=e2-micro \
    --zone="$LOCATION-a" \
    --network-interface=stack-type=IPV4_ONLY,subnet=$VPC_SUBNET,no-address \
    --metadata-from-file=startup-script="./src/cloudsql_auth_proxy_setup.sh" \
    --metadata="CLOUDSQL_INSTANCE=$CLOUDSQL_INSTANCE,CLOUDSQL_CONNECTION_STRING=$CLOUDSQL_CONNECTION_STRING" \
    --scopes="https://www.googleapis.com/auth/cloud-platform"