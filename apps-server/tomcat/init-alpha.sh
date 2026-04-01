#!/bin/bash
set -e

CATALINA_HOME=/usr/local/tomcat
WEBAPPS=$CATALINA_HOME/webapps

# catalina.sh start

echo "⏳ Waiting for WAR extraction..."
sleep 10

echo "⚙️ Updating DB config (partial replace)..."

# Prepare dynamic values
eval $(envsubst < /alpha-conf/db.properties)

for app in $(ls $WEBAPPS | grep -v ROOT); do
  FILE="$WEBAPPS/$app/WEB-INF/classes/SQLProperties.properties"

  if [ -f "$FILE" ]; then
    echo "🔧 Updating DB config in $app"

    sed -i "s|^MYSQL_URL=.*|MYSQL_URL=${MYSQL_URL}|" "$FILE"
    sed -i "s|^MYSQL_USER=.*|MYSQL_USER=${MYSQL_USER}|" "$FILE"
    sed -i "s|^MYSQL_PASSWORD=.*|MYSQL_PASSWORD=${MYSQL_PASSWORD}|" "$FILE"
  fi
done

echo "✅ DB config updated"

echo "🚀 Starting Tomcat..."
catalina.sh run