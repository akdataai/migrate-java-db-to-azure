# 01 - Deploy a Java EE application to Azure

__This guide is part of the [migrate Java EE app to Azure training](../README.md)__

Basics on configuring Maven and deploying a Java EE application to Azure.

---

## Verify Azure Subscription and setup development environment

Set environment variables for storing Azure information, 
particularly Azure Resource Group and Web app names. Then, you can 
export them to your local environment. 

Create `.scripts/setup-env-variables.sh` using the contents below.
Amend the Azure Environment section only to set the Azure Resource Group name, web app name (e.g. petstore-<your initials>), Azure Region, Azure PostgreSQL Database name, admin user name and password.

```bash 
vi .scripts/setup-env-variables.sh
	#!/usr/bin/env bash
	
	# Azure Environment
	export SUBSCRIPTION=your-subscription-id # customize this
	export RESOURCE_GROUP=oss-hack # you may want to customize by supplying a Resource Group name
	export WEBAPP=petstore-ak-eastus # customize this - say, seattle-petstore
	export REGION=eastus
	
	export DATABASE_SERVER=petstoredb
	export DATABASE_ADMIN=pgdba # customize this
	export DATABASE_ADMIN_PASSWORD=Demopass1234567 # customize this
	
	# ======== DERIVED Environment Variable Values ===========
	# Composed secrets for PostgreSQL
	export POSTGRES_SERVER_NAME=${DATABASE_SERVER}
	export POSTGRES_SERVER_ADMIN_LOGIN_NAME=${DATABASE_ADMIN}
	export POSTGRES_SERVER_ADMIN_PASSWORD=${DATABASE_ADMIN_PASSWORD}
	export POSTGRES_DATABASE_NAME=postgres
	
	export POSTGRES_SERVER_FULL_NAME=${POSTGRES_SERVER_NAME}.postgres.database.azure.com
	export POSTGRES_CONNECTION_URL=jdbc:postgresql://${POSTGRES_SERVER_FULL_NAME}:5432/${POSTGRES_DATABASE_NAME}?user=${DATABASE_ADMIN}"&"password=${POSTGRES_SERVER_ADMIN_PASSWORD}"&"sslmode=require
	
	# Composed secrets for Azure Monitor, Log Analtyics and Application Insights
	export LOG_ANALYTICS=${WEBAPP}
	export LOG_ANALYTICS_RESOURCE_ID= # will be set by script
	export WEBAPP_RESOURCE_ID= # will be set by script
	export DIAGNOSTIC_SETTINGS=send-logs-and-metrics
	export APPLICATION_INSIGHTS=${WEBAPP}
	export APPLICATIONINSIGHTS_CONNECTION_STRING= # will be set by script
	
	# ======== Programmatically Set ==========
	
	#IPCONFIG
	export DEVBOX_IP_ADDRESS=$(curl ifconfig.me)
```

Then, set environment variables:
```bash
cd /c/git/migrate-javaee-app-to-azure-training/
source .scripts/setup-env-variables.sh
```

Ensure your Azure CLI is logged into your Azure subscription.

>💡 If using Windows, make sure you enter these commands and all others that follow in Git Bash.

```bash
az login # Sign into an azure account
az account show # See the currently signed-in account.
```

Ensure your default subscription is the one you intend to use for this lab, and if not - 
set the subscription via 
```az account set --subscription ${SUBSCRIPTION}```

# Configure application to deploy to Azure App Service
In this section amend two deployment configuration files to cater for a database migration, not a full redeploy and re-seed of Azure Database for PostgreSQL

Amend the persistence.xml to prevent the deployment dropping and recreating tables in Azure Postgres
```bash
vi src/main/resources/META-INF/persistence.xml
```
	Remove the lines
	      <property name="javax.persistence.schema-generation.database.action" value="drop-and-create"/>
	      <property name="javax.persistence.sql-load-script-source" value="init_db.sql"/>
	
Amend the Azure Postgres datasource parameters, as follows, to reflect the correct JDBC connection string for Azure Database for PostgreSQL
    Note. The connection string is built from $POSTGRES_CONNECTION_URL that is defined in the environment parameters script modified earlier.
    In a later step the $POSTGRES_CONNECTION_URL will be passed to Azure App Service to embed within the startup
```bash    
vi .scripts/3A-postgresql/postgresql-datasource-commands.cli
```
	Replace the data-source line:
	data-source add --name=postgresDS --driver-name=postgres --jndi-name=java:jboss/datasources/postgresDS --connection-url=${POSTGRES_CONNECTION_URL,env.POSTGRES_CONNECTION_URL:jdbc:postgresql://db:5432/postgres} --use-ccm=true --max-pool-size=5 --blocking-timeout-wait-millis=5000 --enabled=true --driver-class=org.postgresql.Driver --exception-sorter-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter --jta=true --use-java-context=true --valid-connection-checker-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker

Amend the pom.xml to include the Azure postgresql resources for Azure App Service deployment
$ vi pom.xml
	…
	          <deployment>
	            <resources>
	              <resource>
	                <type>war</type>
	                <directory>${project.basedir}/target</directory>
	                <includes>
	                  <include>*.war</include>
	                </includes>
	            </resource>
	              <resource>
	                <type>lib</type>
	                <directory>${project.basedir}/.scripts/3A-postgresql</directory>
	                <includes>
	                  <include>*.jar</include>
	                </includes>
	              </resource>
	              <resource>
	                <type>startup</type>
	                <directory>${project.basedir}/.scripts/3A-postgresql</directory>
	                <includes>
	                  <include>*.sh</include>
	                </includes>
	              </resource>
	              <resource>
	                <type>script</type>
	                <directory>${project.basedir}/.scripts/3A-postgresql</directory>
	                <includes>
	                  <include>*.cli</include>
	                  <include>*.xml</include>
	                </includes>
	              </resource>

Enable the Azure App Service for Maven
```bash
mvn com.microsoft.azure:azure-webapp-maven-plugin:1.16.1:config
```
* Supply the Azure Application name given in setup-env-variables.sh (e.g. petstore-<initial>)
* Accept the defaults for the app service plan

This will update the pom.xml to include Azure App Service plugin:
```xml    
<plugins> 

  <!--*************************************************-->
  <!-- Deploy to JBoss EAP in App Service Linux           -->
  <!--*************************************************-->

  <plugin>
    <groupId>com.microsoft.azure</groupId>
    <artifactId>azure-webapp-maven-plugin</artifactId>
    <version>1.16.1</version>
    <configuration>
      <schemaVersion>v2</schemaVersion>
      <subscriptionId>${SUBSCRIPTION}</subscriptionId>
      <resourceGroup>${RESOURCE_GROUP}</resourceGroup>
      <appName>${WEBAPP}</appName>
      <pricingTier>P1v2</pricingTier>
      <region>${REGION}</region>
      <runtime>
        <os>Linux</os>
        <javaVersion>Java 8</javaVersion>
        <webContainer>Jbosseap 7.2</webContainer>
      </runtime>
      <deployment>
        <resources>
          <resource>
            <directory>${project.basedir}/target</directory>
            <includes>
              <include>*.war</include>
            </includes>
          </resource>
        </resources>
      </deployment>
    </configuration>
  </plugin>
    ...
</plugins>
```
## Build a Java EE application
Using Maven you can build and deploy the petstore application into Azure App Service
The deployment process will include creating an Azure App Service Plan and JBOSS Linux Web Application Service within the subscription and resource group defined in the setup-env-variables.sh

```bash
mvn package -Dmaven.test.skip=true -Ddb=postgresql
mvn azure-webapp:deploy
```
Set the Azure App Service with the JDBC PostgreSQL connection parameters to Azure Database for Postgres
```bash
az webapp config appsettings set \
    --resource-group ${RESOURCE_GROUP} --name ${WEBAPP} \
    --settings \
    POSTGRES_CONNECTION_URL=${POSTGRES_CONNECTION_URL}
```

Ensure the correct connection URL, Username and Password is returned:
[
  {
    "name": "POSTGRES_CONNECTION_URL",
    "slotSetting": false,
    "value": "jdbc:postgresql://petstoredb.postgres.database.azure.com:5432/postgres?user=pgdba&password=Demopass1234567&sslmode=require"
  }
]

```text
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] Building Petstore application using Java EE 7 7.0
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- azure-webapp-maven-plugin:1.16.1:deploy (default-cli) @ petstoreee7 ---
...
[INFO] Target Web App doesn't exist. Creating a new one...
[INFO] Creating App Service Plan 'ServicePlan96b599bb-a053-4ea6'...
[INFO] Successfully created App Service Plan.
[INFO] Successfully created Web App.
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 1 resource to /Users/selvasingh/GitHub/selvasingh/migrate-javaee-app-to-azure/target/azure-webapp/seattle-petstore-3596b742-2cf2-4713-b7a4-b88694754bad
[INFO] Trying to deploy artifact to seattle-petstore...
[INFO] Deploying the war file applicationPetstore.war...
[INFO] Successfully deployed the artifact to https://seattle-petstore.azurewebsites.net
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 02:34 min
[INFO] Finished at: 2020-12-29T20:58:59-08:00
[INFO] Final Memory: 56M/790M
[INFO] ------------------------------------------------------------------------
```

## Open Java EE application running on JBoss EAP in App Service Linux

Open the Java EE application running on JBoss EAP in App Service Linux:
```bash
open https://${WEBAPP}.azurewebsites.net
```
![](./media/YAPS-PetStore-H2.jpg)

You can also `curl` the REST API exposed by the Java EE application. The admin REST 
API allows you to create/update/remove items in the catalog, orders or customers. 
You can run the following curl commands:
```bash
curl -X GET https://${WEBAPP}.azurewebsites.net/rest/categories
curl -X GET https://${WEBAPP}.azurewebsites.net/rest/products
curl -X GET https://${WEBAPP}.azurewebsites.net/rest/items
curl -X GET https://${WEBAPP}.azurewebsites.net/rest/countries
curl -X GET https://${WEBAPP}.azurewebsites.net/rest/customers
```

You can also get a JSON representation:
```bash
curl -X GET -H "accept: application/json" https://${WEBAPP}.azurewebsites.net/rest/items
```

Check the Java EE application's Swagger contract:
```bash
curl -X GET https://${WEBAPP}.azurewebsites.net/swagger.json
```

---

⬅️ Previous guide: [03 - Migrate on-premises PostgreSQL database to Azure ](../../step-03-migrate-database-to-azure/README.md)