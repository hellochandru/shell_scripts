#!/bin/bash

# Exit on error
set -e

# Ensure running as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Please run this script as root."
    exit 1
fi

# Import Corretto GPG key and add repo
rpm --import https://yum.corretto.aws/corretto.key
curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

# Install Amazon Corretto 8 JDK
yum install -y java-1.8.0-amazon-corretto-devel --nogpgcheck

# Verify Java installation
java -version

# Install required utilities
yum install -y tar wget tree

# Download and extract Nexus
cd /opt
wget https://download.sonatype.com/nexus/3/nexus-3.70.1-02-java8-unix.tar.gz
tar -xvzf nexus-3.70.1-02-java8-unix.tar.gz
mv /opt/nexus-3.70.1-02 /opt/nexus

# Create nexus user if not exists
id -u nexus &>/dev/null || useradd nexus

# Create sonatype-work directory if not exists
mkdir -p /opt/sonatype-work

# Set permissions
chown -R nexus:nexus /opt/nexus
chown -R nexus:nexus /opt/sonatype-work
chmod -R 775 /opt/nexus
chmod -R 775 /opt/sonatype-work

# Set run_as_user in nexus.rc
NEXUS_RC="/opt/nexus/bin/nexus.rc"
if grep -q '^#run_as_user=' "$NEXUS_RC"; then
    sed -i 's/^#run_as_user=.*/run_as_user="nexus"/' "$NEXUS_RC"
elif grep -q '^run_as_user=' "$NEXUS_RC"; then
    sed -i 's/^run_as_user=.*/run_as_user="nexus"/' "$NEXUS_RC"
else
    echo 'run_as_user="nexus"' >> "$NEXUS_RC"
fi

# Create systemd service file for Nexus
cat <<EOF > /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable/start Nexus
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus
systemctl status nexus