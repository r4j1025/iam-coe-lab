#!/bin/bash
set -e

echo "===== IAM COE Lab Setup ====="

# 1. Install dependencies
echo "📦 Installing Docker, Docker Compose, nginx..."
sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose-plugin nginx apache2-utils

sudo systemctl enable docker && sudo systemctl start docker
sudo usermod -aG docker $USER

# 2. Create shared Docker network
echo "🌐 Creating Docker network..."
docker network create iam-coe-local-net 2>/dev/null || echo "Network already exists"

# 3. Create host folders
echo "📁 Creating host folders..."
sudo mkdir -p /opt/CSVFiles_HRSoft
sudo mkdir -p /opt/CSVFiles_BI_Uploaded
sudo mkdir -p /opt/sp_properties
sudo chmod 777 /opt/CSVFiles_HRSoft /opt/CSVFiles_BI_Uploaded /opt/sp_properties

# 4. Start DB server
echo "🗄️ Starting DB server..."
cd ~/iam-coe-lab/db-server
docker compose up -d
echo "⏳ Waiting for MySQL to initialize..."
sleep 30

# 5. Start LDAP server
echo "📂 Starting LDAP server..."
cd ~/iam-coe-lab/ldap-server
docker compose up -d

# 6. Start Apps server
echo "🚀 Starting Apps server..."
cd ~/iam-coe-lab/apps-server
docker compose build tomcat
docker compose up -d
sleep 30

# 7. Start SailPoint
echo "⛵ Starting SailPoint..."
cd ~/iam-coe-lab/sailpoint
docker compose up -d
sleep 60

# 8. Copy log4j2.properties to host for /properties endpoint
echo "📋 Exposing SailPoint properties..."
MOUNT2=$(docker volume inspect sailpoint_iiq_webapps --format '{{.Mountpoint}}' 2>/dev/null || echo "")
if [ -n "$MOUNT2" ]; then
  sudo cp "$MOUNT2/identityiq/WEB-INF/classes/log4j2.properties" /opt/sp_properties/ 2>/dev/null || true
  sudo chmod 644 /opt/sp_properties/log4j2.properties 2>/dev/null || true
fi

echo ""
echo "===== Setup Complete ====="
echo "✅ All services started"
echo ""
echo "URLs:"
echo "  HRSoft:           https://<VM_IP>/HRSoft/"
echo "  AppraisalSoft:    https://<VM_IP>/AppraisalSoft_JDBC/"
echo "  BI CSV:           https://<VM_IP>/BI_CSV/"
echo "  SailPoint IIQ:    https://<VM_IP>/identityiq/"
echo "  Logs:             https://<VM_IP>/logs/         (coelabuser / coeL@bPa\$\$)"
echo "  Properties:       https://<VM_IP>/properties/   (coelabuser / coeL@bPa\$\$)"
echo "  HRSoft CSV:       https://<VM_IP>/HRSoft_CSVExtract/ (coelabuser / coeL@bPa\$\$)"
echo "  BI CSV Extract:   https://<VM_IP>/BI_CSVExtract/     (coelabuser / coeL@bPa\$\$)"
echo ""
echo "⚠️  Remember to:"
echo "  1. Copy WAR files to apps-server/tomcat/webapps/"
echo "  2. Copy identityiq.war to sailpoint/iiq/"
echo "  3. Configure nginx with SSL certificate"
