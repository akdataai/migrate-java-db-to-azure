# 02 - Create a PostgreSQL Database

__This guide is part of the [migrate Java EE app and PostgreSQL database to Azure training](../README.md)__

Create a PostgreSQL database using commandline tools.

---

## Create and configure Petstore database in Azure Database for PostgreSQL
  
Create a Pet Store database using Azure CLI and PostgreSQL CLI:
  
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