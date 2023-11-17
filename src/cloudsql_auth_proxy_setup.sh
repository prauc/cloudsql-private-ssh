#!/bin/bash

CLOUDSQL_CONNECTION_STRING=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/CLOUDSQL_CONNECTION_STRING -H "Metadata-Flavor: Google")
CLOUDSQL_INSTANCE=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/CLOUDSQL_INSTANCE -H "Metadata-Flavor: Google")

curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.7.2/cloud-sql-proxy.linux.amd64
mv cloud-sql-proxy /usr/local/bin/
chmod +x /usr/local/bin/cloud-sql-proxy

sudo bash -c "cat <<EOF > /etc/systemd/system/cloud-sql-proxy-${CLOUDSQL_INSTANCE}.service
[Unit]
Description=Google Cloud SQL Auth Proxy ${CLOUDSQL_INSTANCE}
After=network.target

[Service]
ExecStart=/usr/local/bin/cloud-sql-proxy --address 0.0.0.0 --private-ip ${CLOUDSQL_CONNECTION_STRING} --port 3306
Restart=always
User=root
Type=simple

[Install]
WantedBy=multi-user.target
EOF"

# Enable and start the service
sudo systemctl enable cloud-sql-proxy-${CLOUDSQL_INSTANCE}.service
sudo systemctl start cloud-sql-proxy-${CLOUDSQL_INSTANCE}.service