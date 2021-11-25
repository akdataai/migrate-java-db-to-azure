# 02 - Create a PostgreSQL Database

__This guide is part of the [migrate Java EE app and PostgreSQL database to Azure training](../README.md)__

Create a PostgreSQL database using commandline tools.

---

## Build and environment variable script to use for our deployments
Set environment variables for storing Azure information, 
particularly Azure Resource Group and Web app names. Then, you can 
export them to your local environment. 

* Using Git Bash create `.scripts/setup-env-variables.sh` using the contents below.
Amend the Azure Environment section only to set the Azure Resource Group name, web app name (e.g. petstore-<your initials>), Azure Region, Azure PostgreSQL Database name, admin user name and password.

```bash 
vi .scripts/setup-env-variables.sh
```
```text
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
* Source the environment variables:
```bash
cd /c/git/migrate-javaee-app-to-azure-training/
source .scripts/setup-env-variables.sh
```

## Create and configure Petstore database in Azure Database for PostgreSQL
  
* Create a Pet Store database using Azure CLI and PostgreSQL CLI:
  
```bash
az postgres flexible-server create --resource-group oss-hack \
--name ${DATABASE_SERVER} \
--resource-group ${RESOURCE_GROUP} \
--admin-user ${DATABASE_ADMIN} \
--admin-password ${DATABASE_ADMIN_PASSWORD} \
--sku-name Standard_B1ms \
--tier Burstable \
--public-access all
```

## Check database connectivity using psql

  
>💡 - you can reinstall `psql` command line tool using `brew reinstall postgresql`.
  
When you migrate Java applications to cloud, you will be considering moving data to cloud. 
To accelerate your transition to cloud, 
Azure offers plenty of options to [migrate your data](https://azure.microsoft.com/en-us/services/database-migration/) 
to cloud.
  
Also, for your convenience, there is a [cheat sheet for PostgreSQL CLI](http://www.postgresqltutorial.com/postgresql-cheat-sheet/).
   
⬅️ Previous guide: [01 - Deploy a Java EE application to VM](../step-01-deploy-java-ee-app-to-VM/README.md)
  
➡️ Next guide: [03 - Migrate on-premises database](../step-03-migrate-database-to-azure/README.md)