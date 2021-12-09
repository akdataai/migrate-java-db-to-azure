#!/bin/bash
export WILDFLY_RELEASE="25.0.1"
wget https://github.com/wildfly/wildfly/releases/download/25.0.1.Final/wildfly-25.0.1.Final.tar.gz
tar xvf wildfly-$WILDFLY_RELEASE.Final.tar.gz
mv wildfly-25.0.1.Final /opt/wildfly
sudo groupadd --system wildfly
sudo useradd -s /sbin/nologin --system -d /opt/wildfly  -g wildfly wildfly
sudo mkdir /etc/wildfly
sudo cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.conf /etc/wildfly/
sudo cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/
sudo cp /opt/wildfly/docs/contrib/scripts/systemd/launch.sh /opt/wildfly/bin/
sudo chmod +x /opt/wildfly/bin/launch.sh
sudo chown -R wildfly:wildfly /opt/wildfly
sudo systemctl daemon-reload
sudo restorecon -Rv /opt/wildfly/bin/
setenforce 0

cat >> ~/.bashrc <<EOF
export WildFly_BIN="/opt/wildfly/bin/"
export PATH=\$PATH:/opt/wildfly/bin/
EOF

systemctl status wildfly

# NEED TO SETUP WILDFLY ADMIN user HERE
# Change Wildfly standalone.sh to accept input from 0.0.0.0

systemctl restart wildfly

sudo dnf -qy module disable postgresql
sudo dnf -qy module enable postgresql:12
sudo dnf -y install postgresql-server
sudo dnf -y install postgresql-contrib
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

# NEED TO CHANGE pg_hba.conf to listen on all addresses for IPv4

sudo systemctl restart postgresql

# Need to setup password for PGUser