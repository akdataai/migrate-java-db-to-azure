#!/usr/bin/env bash

# Azure Environment
export SUBSCRIPTION=your-subscription-id # customize this
export RESOURCE_GROUP=migrate-java-ee-app-to-azure # you may want to customize by supplying a Resource Group name
export WEBAPP=your-web-app-name # customize this - say, seattle-petstore
export REGION=westus

export DATABASE_SERVER=your-database-server-name # customize this
export DATABASE_ADMIN=selvasingh # customize this
export DATABASE_ADMIN_PASSWORD=SuperS3cr3t # customize this

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
