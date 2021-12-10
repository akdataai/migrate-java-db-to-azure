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

##############
# HARDCODED ADMIN PASSWORD! DO NOT USE IN ANYTHING RESEMBLING PRODUCTION!!!!
# FOR DEMO/WORKSHOP PURPOSES ONLY!!!! 
##############
/opt/wildfly/bin/add-user.sh -u 'adminuser1' -p 'password1!' -g 'admin'
##############
# YOU HAVE BEEN WARNED
##############

# Change Wildfly standalone.sh to accept input from 0.0.0.0
sed -i 's#$WILDFLY_HOME/bin/standalone.sh -c $2 -b $3#$WILDFLY_HOME/bin/standalone.sh -c $2 -b $3 -bmanagement=0.0.0.0#g' /opt/wildfly/bin/launch.sh

systemctl restart wildfly

sudo dnf -qy module disable postgresql
sudo dnf -qy module enable postgresql:12
sudo dnf -y install postgresql-server
sudo dnf -y install postgresql-contrib
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

##############
# HARDCODED POSTGRESS ALLOW ALL HOST BASED AUTH! DO NOT USE IN ANYTHING RESEMBLING PRODUCTION!!!!
# FOR DEMO/WORKSHOP PURPOSES ONLY!!!! 
##############
sed -i 's#local   all             all                                     ident#local   all             all                                     trust#g' /var/lib/pgsql/data/pg_hba.conf
sed -i 's#host    all             all             127.0.0.1/32            ident#host    all             all             0.0.0.0/0               password#g' /var/lib/pgsql/data/pg_hba.conf
##############
# YOU HAVE BEEN WARNED (Again)
##############


# Need to change the postgresql.conf to listen on all addresses too
sed -i 's|#listen_addresses|listen_addresses|g' /var/lib/pgsql/data/postgresql.conf


sudo systemctl restart postgresql

# Need to setup password for PGUser
cp /root/SetPostgresUserAccountPassword.sql /var/lib/pgsql
cd /var/lib/pgsql
chmod u+r SetPostgresUserAccountPassword.sql
chown postgres:postgres SetPostgresUserAccountPassword.sql
sudo -u postgres psql -U postgres postgres -f /var/lib/pgsql/SetPostgresUserAccountPassword.sql