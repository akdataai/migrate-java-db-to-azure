# 00 - Setup your environment

__This guide is part of the [migrate Java EE app and PostgreSQL database to Azure training](../README.md)__

Setting up all the necessary prerequisites in order to expeditiously complete the lab.

---
## Build Azure "on-premises" environment

Within your Azure subscription the Bicep template within this repository can be used to deploy
* Azure Linux VM - "oss-hack-pgsql" - to host the Pet Store Java application to WildFly and PostgreSQL database
* Azure Windows VM - "oss-hack-rdp" - to deploy the Pet Store Java application to both on-premises VM and into Azure
* Virtual Network - "oss-hack-vnet" - 10.0.0.0/16
  * Subnet - "PgSubnet" - 10.0.1.0/24
  * Subnet - "rdpSubnet" - 10.0.2.0/24

* To deploy the bicep template use Azure Cloud Shell 
    * Create an Azure Resource Group to deploy into (e.g. oss-hack)
    * Upload the package to your Azure Cloud subscription (Change to Bash Shell...)
    * Unpack the OSS-App-DB-Bicep.zip
    * Navigate to the unpacked folder
    * Edit "./parameters/parameters.json" to reflect the resource group to deploy into
    * Run the Bicep template to deploy
        az deployment group create --template-file ./main.bicep  --parameters ./parameters/parameters.json -g "oss-hack"

* Following deployment
    * Validate the Bicep deployment has completed successfully
    * Create a Network Security Group upon the PgSubnet with the following inbound rules
      * SSH - 22
      * WildFly Admin - 9990
      * Pet Store Application - 8080
      * PostgreSQL - 5432
    * Create an Azure Bastion to connect to "oss-hack-rdp"
      * Navigate to the VM
      * Select Connect and choose Bastion
      * Deploy Azure Bastion Service accepting the defaults to deploy into a new Subnet within the "oss-hack-vnet"

---
## Prerequisites

* Login to "oss-hack-rdp" 
  * The training lab requires the following to be installed on your development machine or deployed Azure Remote Desktop:
    * Install Edge Browser
      * https://www.microsoft.com/en-us/edge?r=1
  
    * [JDK 1.8](https://www.azul.com/downloads/azure-only/zulu/?&version=java-8-lts&architecture=x86-64-bit&package=jdk)
      * As part of the installation select the option to set the JAVA_HOME
        * The environment variable `JAVA_HOME` should be set to the path of `javac` in the JDK installation.
  
    * [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) 
    
    * The Bash shell. 
      * GitBash is pre-installed upon "oss-hack-rdp"
      * Where a local desktop is used
        * Use [Git Bash that accompanies the Windows distribution of Git](https://git-scm.com/download/win)
    
    * [Maven](http://maven.apache.org/)
      * Download and unpack to c:\maven
      * $ mkdir /c/mv
      * $ cd /c/mvn
      * $ mv /c/Users/demouser/Downloads/apache-maven-3.8.3-bin.zip ./
      * $ unzip apache-maven-3.8.3-bin.zip
      * Set the PATH to reference the Maven Installation
    
    * PostgreSQL Database tools:
      * [PostgreSQL CLI](https://www.postgresql.org/docs/current/app-psql.html)
    
    * The [`jq` utility](https://stedolan.github.io/jq/download/). 
      * On Windows, download [this Windows port of JQ](https://github.com/stedolan/jq/releases)
        * Download to c:\jq
      * Launch GitBash and edit the the `~/.bashrc` file to point to jq: 
       ```bash
      alias jq=/c/jq/jq-win64.exe
      ```
    * Using Git Bash download the Azure App Service for Java Source repository to c:/git
      * $ mkdir /c/git/
      * $ cd /c/git
      * $ git clone https://github.com/Azure-Samples/migrate-javaee-app-to-azure-training.git
    
    * Download and install Putty MSI
      *    https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

---

➡️ Next guide: [01 - Deploy a Java EE application to VM](../step-01-deploy-java-ee-app-to-VM/README.md)
