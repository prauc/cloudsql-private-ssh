# private CloudSQL Bastion-Host Proxy

This script will deploy all required components, like `VPC Firewall`, `Cloud NAT`, `Cloud Router` and your Bastion-Host VM,
so you can securely connect to your CloudSQL.

## Project setup

```bash
chmod +x ./install.sh
./install.sh
```

## Start connection

After you have installed all necessary components, start your ssh IAP-tunnel via:

```bash
gcloud compute ssh --zone ZONE BASTION_HOST --tunnel-through-iap --project PROJECT --ssh-flag="-4 -L8888:localhost:3306 -N -q -f"
```

still will start your background ssh-tunnel-process.

You can now connect to your CloudSQL Instance:

```bash
mysql -h 127.0.0.1 -P 8888 -u root -p
```

## Input Parameters

### Location

Your GCP region. e.g. `europe-west4`

### GCP Project ID

Your GCP Project ID.

### VPC

VPC, to deploy your bastion host components, like `Cloud Router` and `Cloud NAT`

### VPC Subnet

VPC Subnet, to deploy your bastion host.

### CloudSQL Instance

Your CloudSQL Instance, to connect.
