#!/bin/bash
set -e

mkdir -p /opt/CSVFiles_HRSoft && chmod 777 /opt/CSVFiles_HRSoft
mkdir -p /opt/CSVFiles_BI && chmod 777 /opt/CSVFiles_BI
mkdir -p /opt/CSVFiles_BI_Uploaded && chmod 777 /opt/CSVFiles_BI_Uploaded
mkdir -p /opt/sp_logs && chmod 777 /opt/sp_logs
mkdir -p /opt/sp_properties && chmod 777 /opt/sp_properties

CATALINA_HOME=/usr/local/tomcat
WEBAPPS=$CATALINA_HOME/webapps

echo "⏳ Waiting for WAR extraction..."
sleep 10

echo "⚙️ Patching BI upload path..."
sed -i 's#FILEPATH_TO_STORE_UPLOADEDFILE=/opt/CSVFiles_BI/#FILEPATH_TO_STORE_UPLOADEDFILE=/opt/CSVFiles_BI_Uploaded/#' \
  $WEBAPPS/BI_CSV/WEB-INF/classes/SQLProperties.properties 2>/dev/null || true

echo "🚀 Starting Tomcat..."
exec /usr/local/tomcat/bin/catalina.sh run
