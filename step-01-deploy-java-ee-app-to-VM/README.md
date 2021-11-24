# 01 - Deploy a Java EE application to Azure VM

__This guide is part of the [migrate Java EE app to Azure training](../README.md)__

Basics on configuring Maven and deploying a Java EE application to Azure.

## Deploy Pet Store Application to Linux VM "oss-hack-pg"
    
* From the RDP "oss-hack-rdp" use Putty to login to Azure VM 

* Prepare for WildFly installation
    * Sudo to root
        ```bash
        sudo su - 
        ```
    * Update the VM OS
        ```bash
        yum update -y 
        ```
    * Install Java 8 JDK
        ```bash
        yum install java-1.8.0-openjdk-devel
        java -version
        ```
    * Install wget
        ```bash
        yum -y install wget
        ```
    * Install WildFly 
        ```bash
        export WILDFLY_RELEASE="25.0.1"
        wget https://github.com/wildfly/wildfly/releases/download/25.0.1.Final/wildfly-25.0.1.Final.tar.gz
        tar xvf wildfly-$WILDFLY_RELEASE.Final.tar.gz
        mv wildfly-25.0.1.Final /opt/wildfly
        ```
    * Start WildFly as a service
        ```bash
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
        sudo systemctl start wildfly
        sudo systemctl enable wildfly
        systemctl status wildfly
        ss -tunelp | grep 8080
        sudo /opt/wildfly/bin/add-user.sh
        ```
    * Set WildFly path for login
        ```bash
        cat >> ~/.bashrc <<EOF
	    export WildFly_BIN="/opt/wildfly/bin/"
	    export PATH=\$PATH:\$WildFly_BIN
	    EOF
        source ~/.bashrc
        ```
    * Set WildFly to listen on all network devices
        ```bash
        vi /opt/wildfly/bin/launch.sh   
	        $WILDFLY_HOME/bin/standalone.sh -c $2 -b $3 -bmanagement=0.0.0.0
        ```
    * Validate WildFly is running on port 9990
        ```bash
        ss -tunelp | grep 9990
        ```

* Deploy PostgreSQL 12
  * Install PostgreSQL 12
    ```bash
    sudo yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    ```
    ```bash
    sudo dnf -qy module disable postgresql
    ```
    ```bash
    sudo dnf module enable postgresql:12
    ```
    ```bash
    sudo dnf -y install postgresql12 postgresql12-server
    ```
    ```bash
    sudo dnf -y install postgresql-contrib
    ```
  
  * Initialise PostgreSQL 
    ```bash
    sudo postgresql-setup --initdb
    ```
    ```bash
    sudo systemctl start postgresql
    ```
    ```bash
    sudo systemctl enable postgresql
    ```

  * Configure PostgreSQL to listen and permit connections on all network devices
    * Edit the pg_hba.conf
    * Set IPv4 to accept connections from all addresses
    * Set the local and IPv4 connection method to trust (not ident)
        ```bash
        vi /var/lib/pgsql/data/pg_hba.conf
	        # TYPE  DATABASE        USER            ADDRESS                 METHOD
	        # "local" is for Unix domain socket connections only
	        local   all             all                                     **trust**
	        # IPv4 local connections:
	        host    all             all             **0.0.0.0/0 **              **trust**
        ```
    * Set PostgreSQL to listen on all addresses
        ```bash
        vi /var/lib/pgsql/data/postgresql.conf
	        listen_addresses = '*'
        ```
    * Restart PostgreSQL
        ```bash
        sudo systemctl restart postgresql
        ```
    * Set the PostgreSQL default "postgresql" user password (example below uses the password Demopass1234567)
        ```bash
        psql -U postgres postgres
	    postgres=# alter user postgres password 'Demopass1234567';
        ```
    * Check connection to PostgreSQL
        ```bash
        psql "dbname=postgres host=10.0.1.4 user=postgres password=Demopass1234567 port=5432"
        ```


## Deploy Pet Store Application to WildFly and PostgreSQL

* From the Lab VM "oss-hack-rdp"
  * Download PostgreSQL JDBC driver to the Lab VM
  https://jdbc.postgresql.org/download/postgresql-42.3.1.jar

  * Using Edge browser, login to the Wildfly Admin Console
    http://10.0.1.4:9990

  * Create the PostgreSQL Data Source
    * Navigate to Deployments 
    * Choose the PostgreSQL JDBC driver downloaded above
    * Accept the Name and Finish
  
  * Navigate to 
    * Navigate to Configuration -> Datasources & Drivers
    * Add Data Source (not the XA)
      * Give the JNDI Name as:
        java:jboss/datasources/postgresDS
      * Select the PostgreSQL Driver (Downloaded above)
      * Set the connection URL to 
        jdbc:postgresql://localhost:5432/postgres
      * Set the Username to postgres
      * Set the password as set previously (e.g. Demopass1234567)
    * Test the connection is successful, review and deploy

# Package Pet Store application to deploy
  * Launch Git Bash session
  * Navigate to the git package
    ```bash
    cd /c/git/migrate-javaee-app-to-azure-training
    ```
  * Copy the PostgreSQL persistence file to the META-INF folder for deployment
    ```bash
    cp migrate-javaee-app-to-azure-training/.scripts/persistence-postgresql.xml ../src/main/resources/META-INF/persistence.xml
    ```
  * Build the Pet Store WAR file using Maven for deployment
    ```bash
    mvn clean compile -Dmaven.test.skip=true
    mvn clean package -Dmaven.test.skip=true
    mvn clean install -Dmaven.test.skip=true
    ```

# Deploy to Pet Store Wildfly
  * Login to Administration Console
    http://10.0.1.4:9990
  * Add a new deployment
  * Select the application Petstore.war
    * c:\git\migrate-javaee-app-to-azure-training\target\applicationPetstore.war
  * Select next through to deploy

# In browser test the application is running:
  * Using Edge navigate to 
    http://10.0.1.4:8080/applicationPetstore/shopping/main.xhtml

# Check the deployment has populated the PostgreSQL database
  * Using psql from Git Bash connect to PostgreSQL and check the tables and records have been deployed 
    ```bash
    psql "dbname=postgres host=10.0.1.4 user=postgres password=Demopass1234567 port=5432"
    postgres=# \dt
                        List of relations
            Schema |        Name        | Type  |  Owner
            --------+--------------------+-------+----------
            public | category           | table | postgres
            public | country            | table | postgres
            public | customer           | table | postgres
            public | item               | table | postgres
            public | order_line         | table | postgres
            public | product            | table | postgres
            public | purchase_order     | table | postgres
            public | t_order_order_line | table | postgres
            (8 rows)
    postgres=# select * from customer;
    ```
---

⬅️ Previous guide: [00 - Prerequisites and Setup](../step-00-setup-your-environment/README.md)

➡️ Next guide: [02 - Create a database](../step-02-create-azure-postgresql-database/README.md)
