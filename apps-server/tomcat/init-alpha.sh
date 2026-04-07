#!/bin/bash
set -e

CATALINA_HOME=/usr/local/tomcat
WEBAPPS=$CATALINA_HOME/webapps

# catalina.sh start

echo "⏳ Waiting for WAR extraction..."
sleep 10

echo "⚙️ Updating DB config (partial replace)..."

echo "🚀 Starting Tomcat..."
catalina.sh run