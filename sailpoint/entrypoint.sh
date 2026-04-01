#!/bin/bash
set -e

echo "🚀 Starting SailPoint IIQ..."

# echo "---- ENV DEBUG ----"
# env | sort
# echo "-------------------"

# -------------------------------
# CONFIG
# -------------------------------
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}

DB_ROOT_USER=${DB_ROOT_USER}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
IIQ_HOME=/opt/iiq
CATALINA_HOME=/usr/local/tomcat
IIQ_WEBAPP="$CATALINA_HOME/webapps/identityiq"
INIT_FLAG="$IIQ_HOME/.initialized"

# -------------------------------
# WAIT FOR DB
# -------------------------------
echo "⏳ Waiting for DB..."
until nc -z $DB_HOST $DB_PORT; do
  sleep 3
done
echo "✅ DB reachable"

# -------------------------------
# INIT PHASE (RUN ONLY ONCE)
# -------------------------------
if [ ! -f "$INIT_FLAG" ]; then
  echo "🛠️ First-time initialization..."


	# -------------------------------
	# CREATE DB IF NOT EXISTS
	# -------------------------------
	echo "🔍 Checking DB..."

	DB_EXISTS=$(mysql -h $DB_HOST -u$DB_ROOT_USER -p$DB_ROOT_PASSWORD -e "SHOW DATABASES LIKE '$DB_NAME';" | grep $DB_NAME || true)

	if [ -z "$DB_EXISTS" ]; then
	echo "⚠️ Creating DB..."

	mysql -h $DB_HOST -u$DB_ROOT_USER -p$DB_ROOT_PASSWORD <<EOF
CREATE DATABASE $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF

	echo "✅ DB created"
	else
	echo "✅ DB exists"
	fi

	# -------------------------------
	# EXTRACT WAR (ONLY ONCE)
	# -------------------------------
	if [ ! -d "$IIQ_WEBAPP" ]; then
	echo "📦 Extracting WAR..."

	mkdir -p $IIQ_WEBAPP
	unzip -q $IIQ_HOME/*.war -d $IIQ_WEBAPP

	echo "✅ WAR extracted"
	else
	echo "⏭️ WAR already extracted"
	fi

	# -------------------------------
	# GENERATE iiq.properties
	# -------------------------------
	echo "⚙️ Generating iiq.properties..."

	pwd
	envsubst < $IIQ_HOME/conf/iiq.properties.template > "$IIQ_WEBAPP/WEB-INF/classes/iiq.properties"
	# envsubst < $IIQ_HOME/conf/build.properties.template > "$IIQ_WEBAPP/WEB-INF/classes/build.properties"
	echo "✅ Config ready"

	# -------------------------------
	# CHECK IF IIQ INITIALIZED
	# -------------------------------
	INIT_CHECK=$(mysql -h $DB_HOST -u$DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='spt_identity';" | tail -n 1 || echo 0)

	if [ "$INIT_CHECK" -eq 0 ]; then
		echo "⚠️ Initializing DB schema..."

		DB_SCRIPT=$(find "$IIQ_WEBAPP/WEB-INF/database" -name "create_identityiq_tables-*.mysql" | head -n 1)

		mysql -h $DB_HOST -u$DB_ROOT_USER -p$DB_ROOT_PASSWORD $DB_NAME < "$DB_SCRIPT"

		echo "✅ Schema created"
	else
		echo "✅ Schema already exists"
	fi

	# -------------------------------
	# IIQ IMPORT (RELIABLE)
	# -------------------------------
	FLAG_FILE="$IIQ_HOME/.import_done"

	if [ ! -f "$FLAG_FILE" ]; then
	echo "⚙️ Running IIQ import..."

	cd "$IIQ_WEBAPP/WEB-INF/bin"

	chmod +x ./iiq
	sed -i 's/\r$//' ./iiq

	# Create command file
	cat <<EOF > /tmp/iiq_import.txt
import init.xml
import init-lcm.xml
exit
EOF

	# Run import using file input (VERY IMPORTANT)
	bash ./iiq console < /tmp/iiq_import.txt

	echo "✅ Import completed"

	touch "$FLAG_FILE"
	else
	echo "⏭️ Import already done"
	fi

else
  echo "⏭️ Already initialized → skipping setup"
fi


# -------------------------------
# BUILD WAR (ROBUST)
# -------------------------------
if [ "$BUILD_FROM_CODE" = "true" ]; then
  echo "🔨 Building IIQ WAR using Ant..."

  cd $IIQ_HOME/code

  if [ ! -f "build.xml" ]; then
    echo "❌ build.xml not found in code/"
    exit 1
  fi

  ant clean war

  echo "🔍 Searching for generated WAR..."

  # Prefer identityiq war specifically
  BUILT_WAR=$(find . -type f -name "identityiq*.war" | sort | tail -n 1)

  if [ -z "$BUILT_WAR" ]; then
    echo "❌ No WAR file found after build"
    exit 1
  fi

  echo "✅ Found WAR: $BUILT_WAR"

  # Copy to standard location
#   cp "$BUILT_WAR" "$CATALINA_HOME/webapps/identityiq.war"

  echo "✅ WAR copied to $CATALINA_HOME/webapps/identityiq.war"

  unzip -n "$BUILT_WAR" -d "$IIQ_WEBAPP"

  echo "✅ Extracted the WAR to $IIQ_WEBAPP"
  envsubst < $IIQ_HOME/conf/iiq.properties.template > "$IIQ_WEBAPP/WEB-INF/classes/iiq.properties"
  
  cd "$IIQ_WEBAPP/WEB-INF/bin"
  chmod +x ./iiq
  sed -i 's/\r$//' ./iiq
# Create command file
  cat <<EOF > /tmp/iiq_custom_import.txt
import sp.init-custom.xml
exit
EOF
  echo "Running Custom Import..."
  bash ./iiq console < /tmp/iiq_custom_import.txt
else
  echo "❌ No Build files Found"
fi

# -------------------------------
# START TOMCAT
# -------------------------------
echo "🚀 Starting Tomcat..."
catalina.sh run 