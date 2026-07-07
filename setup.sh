#!/bin/bash
# ============================================================
# IAM COE Lab — Full Setup Script
# Run once on a fresh Ubuntu 24.04/26.04 VM with Docker installed
# Usage: bash setup.sh
# ============================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "===== IAM COE Lab Setup ====="

# ── 0. Get VM IP ──────────────────────────────────────────────────────────────
VM_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip \
  2>/dev/null || curl -s ifconfig.me)
echo "🌍 VM IP: $VM_IP"

# ── 1. Install dependencies ───────────────────────────────────────────────────
echo "📦 Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release \
  git git-lfs openssl nginx apache2-utils binutils

# Install Docker if not already present
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
fi
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

# docker-compose shim for legacy scripts
if ! command -v docker-compose &>/dev/null; then
  sudo tee /usr/local/bin/docker-compose >/dev/null <<'EOF'
#!/usr/bin/env bash
exec docker compose "$@"
EOF
  sudo chmod +x /usr/local/bin/docker-compose
fi

# ── 2. Pull Git LFS files (WARs + SailPoint only — skip nothing) ──────────────
echo "📥 Pulling Git LFS files..."
git lfs install
# Pull WARs first (fast, ~20 MB total)
git lfs pull -I "apps-server/tomcat/webapps/*.war"
# Pull SailPoint source (slow, ~770 MB — be patient)
echo "⏳ Pulling SailPoint source zip (770 MB, may take several minutes)..."
git lfs pull -I "sailpoint/code/base/ga/identityiq-8.5.zip"
git lfs pull -I "sailpoint/iiq/identityiq.war"

# Verify WARs are real binaries not pointer stubs
WAR_SIZE=$(stat -c%s apps-server/tomcat/webapps/HRSoft.war 2>/dev/null || echo 0)
if [ "$WAR_SIZE" -lt 1000000 ]; then
  echo "❌ WAR files look like LFS pointer stubs (size: $WAR_SIZE). Re-run: git lfs pull"
  exit 1
fi
echo "✅ LFS files verified"

# ── 3. Rename WARs to match target URL context paths ─────────────────────────
echo "🔁 Renaming WARs..."
cd "$REPO_DIR/apps-server/tomcat/webapps"
[ -f BusinessIntelligenceApplication_CSV.war ] && \
  mv BusinessIntelligenceApplication_CSV.war BI_CSV.war
[ -f TimeSheetApplication_LDAP.war ] && \
  mv TimeSheetApplication_LDAP.war TimeSheet_LDAP.war
cd "$REPO_DIR"
echo "✅ WARs renamed"

# ── 4. Create shared Docker network ──────────────────────────────────────────
echo "🌐 Creating Docker network..."
docker network create iam-coe-local-net 2>/dev/null || echo "  Network already exists"

# ── 5. Create all required host folders ──────────────────────────────────────
echo "📁 Creating host folders..."
sudo mkdir -p /opt/CSVFiles_HRSoft
sudo mkdir -p /opt/CSVFiles_BI
sudo mkdir -p /opt/CSVFiles_BI_Uploaded
sudo mkdir -p /opt/sp_logs
sudo mkdir -p /opt/sp_properties
sudo chmod 777 /opt/CSVFiles_HRSoft /opt/CSVFiles_BI \
               /opt/CSVFiles_BI_Uploaded /opt/sp_logs /opt/sp_properties

# ── 6. Start DB server ────────────────────────────────────────────────────────
echo "🗄️  Starting DB server..."
cd "$REPO_DIR/db-server"
docker compose up -d
echo "⏳ Waiting for MySQL to initialize (30s)..."
sleep 30
# Confirm it's actually ready
until docker exec mysql_db mysql -uroot -p'I@mR00t' -e "SELECT 1" &>/dev/null; do
  echo "  Still waiting for MySQL..."
  sleep 5
done
echo "✅ MySQL ready"

# ── 7. Start LDAP server ──────────────────────────────────────────────────────
echo "📂 Starting LDAP server..."
cd "$REPO_DIR/ldap-server"
docker compose up -d
sleep 5
echo "✅ LDAP ready"

# ── 8. Build and start Apps server (Tomcat + WARs) ───────────────────────────
echo "🚀 Building and starting Apps server..."
cd "$REPO_DIR/apps-server"
docker compose build tomcat
docker compose up -d
echo "⏳ Waiting for Tomcat to deploy WARs (45s)..."
sleep 45
# Verify apps are actually responding
until curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/HRSoft/ | grep -q "200"; do
  echo "  Waiting for Tomcat..."
  sleep 10
done
echo "✅ Tomcat apps ready"

# ── 9. Setup Tomcat auth contexts ─────────────────────────────────────────────
echo "🔒 Setting up Tomcat auth contexts..."

# Register context XMLs (Tomcat reads these from conf/Catalina/localhost/)
TOMCAT_CTX_DIR=/usr/local/tomcat/conf/Catalina/localhost

# HRSoft_CSVExtract
docker exec -u root tomcat_apps bash -c "mkdir -p $TOMCAT_CTX_DIR && cat > $TOMCAT_CTX_DIR/HRSoft_CSVExtract.xml <<'CTXEOF'
<Context docBase=\"/opt/CSVFiles_HRSoft\" path=\"/HRSoft_CSVExtract\">
  <Valve className=\"org.apache.catalina.authenticator.BasicAuthenticator\"/>
</Context>
CTXEOF"

# BI_CSVExtract
docker exec -u root tomcat_apps bash -c "cat > $TOMCAT_CTX_DIR/BI_CSVExtract.xml <<'CTXEOF'
<Context docBase=\"/opt/CSVFiles_BI_Uploaded\" path=\"/BI_CSVExtract\">
  <Valve className=\"org.apache.catalina.authenticator.BasicAuthenticator\"/>
</Context>
CTXEOF"

# logs
docker exec -u root tomcat_apps bash -c "cat > $TOMCAT_CTX_DIR/logs.xml <<'CTXEOF'
<Context docBase=\"/opt/sp_logs\" path=\"/logs\">
  <Valve className=\"org.apache.catalina.authenticator.BasicAuthenticator\"/>
</Context>
CTXEOF"

# properties
docker exec -u root tomcat_apps bash -c "cat > $TOMCAT_CTX_DIR/properties.xml <<'CTXEOF'
<Context docBase=\"/opt/sp_properties\" path=\"/properties\">
  <Valve className=\"org.apache.catalina.authenticator.BasicAuthenticator\"/>
</Context>
CTXEOF"

# Create web.xml for each context (directory listing + security constraint)
for CTX_FOLDER in /opt/CSVFiles_HRSoft /opt/CSVFiles_BI_Uploaded /opt/sp_logs /opt/sp_properties; do
  sudo mkdir -p "$CTX_FOLDER/WEB-INF"
  sudo tee "$CTX_FOLDER/WEB-INF/web.xml" >/dev/null <<'WEBEOF'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
         http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
  <servlet>
    <servlet-name>default</servlet-name>
    <servlet-class>org.apache.catalina.servlets.DefaultServlet</servlet-class>
    <init-param><param-name>listings</param-name><param-value>true</param-value></init-param>
  </servlet>
  <servlet-mapping>
    <servlet-name>default</servlet-name>
    <url-pattern>/</url-pattern>
  </servlet-mapping>
  <security-constraint>
    <web-resource-collection>
      <web-resource-name>Protected</web-resource-name>
      <url-pattern>/*</url-pattern>
    </web-resource-collection>
    <auth-constraint>
      <role-name>coelab</role-name>
    </auth-constraint>
  </security-constraint>
  <login-config>
    <auth-method>BASIC</auth-method>
    <realm-name>COE Lab</realm-name>
  </login-config>
  <security-role>
    <role-name>coelab</role-name>
  </security-role>
</web-app>
WEBEOF
  sudo chmod 644 "$CTX_FOLDER/WEB-INF/web.xml"
done

echo "✅ Tomcat auth contexts configured"

# ── 10. Start SailPoint (first-time build — takes 1-2 hours) ─────────────────
echo "⛵ Starting SailPoint IIQ (first-time build — this takes 1-2 hours, do not interrupt)..."
cd "$REPO_DIR/sailpoint"
docker compose up -d --build

echo "⏳ Monitoring SailPoint build progress..."
echo "   (Checking every 5 minutes — first ready signal may take 60-90+ minutes)"
SP_READY=false
for i in $(seq 1 30); do
  sleep 300
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/identityiq/ 2>/dev/null || echo "000")
  echo "  [$(($i * 5))min] SailPoint HTTP status: $STATUS"
  if [ "$STATUS" = "200" ] || [ "$STATUS" = "302" ]; then
    SP_READY=true
    break
  fi
done

if [ "$SP_READY" = "false" ]; then
  echo "⚠️  SailPoint did not become ready within 150 minutes."
  echo "   Check with: docker logs --tail 50 sailpoint"
  echo "   Continuing setup — SailPoint may still be building in the background."
else
  echo "✅ SailPoint IIQ ready"
fi

# ── 11. Enable SailPoint file logging + expose properties ─────────────────────
echo "📋 Enabling SailPoint file logging..."
MOUNT2=$(docker volume inspect sailpoint_iiq_webapps --format '{{.Mountpoint}}' 2>/dev/null || echo "")
if [ -n "$MOUNT2" ] && [ -f "$MOUNT2/identityiq/WEB-INF/classes/log4j2.properties" ]; then
  F="$MOUNT2/identityiq/WEB-INF/classes/log4j2.properties"
  sudo cp "$F" "$F.bak"
  # Remove commented Windows paths and add Linux file appender
  sudo sed -i '/#appender.file.fileName=C:/d' "$F"
  sudo sed -i '/#appender.meter.fileName=C:/d' "$F"
  sudo tee -a "$F" >/dev/null <<'EOF'

# File appender — added for /logs endpoint
appender.file.type=File
appender.file.name=file
appender.file.fileName=/opt/iiq/logs/sailpoint.log
appender.file.layout.type=PatternLayout
appender.file.layout.pattern=%d{ISO8601} %5p %t %c{4}:%L - %m%n
rootLogger.appenderRef.file.ref=file
EOF
  # Create log dir inside sailpoint container
  docker exec -u root sailpoint mkdir -p /opt/iiq/logs
  docker exec -u root sailpoint chmod 777 /opt/iiq/logs
  # Copy active log4j2.properties to the sp_properties host folder for browsing
  sudo cp "$F" /opt/sp_properties/log4j2.properties
  sudo chmod 644 /opt/sp_properties/log4j2.properties
  docker restart sailpoint
  sleep 30
  echo "✅ SailPoint file logging enabled"
else
  echo "⚠️  SailPoint volume not found — skipping log4j setup (SailPoint may still be building)"
fi

# ── 12. Generate SSL cert + configure nginx ───────────────────────────────────
echo "🔐 Generating self-signed SSL certificate..."
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 825 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/iamcoe.key \
  -out /etc/nginx/ssl/iamcoe.crt \
  -subj "/C=IN/O=IAMCOE Labs/CN=${VM_IP}" \
  -addext "subjectAltName=IP:${VM_IP}"
echo "✅ SSL cert created (CN/SAN = $VM_IP)"

echo "🌐 Configuring nginx..."
sudo tee /etc/nginx/sites-available/iamcoe.conf >/dev/null <<EOF
server {
    listen 80;
    server_name $VM_IP;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $VM_IP;

    ssl_certificate     /etc/nginx/ssl/iamcoe.crt;
    ssl_certificate_key /etc/nginx/ssl/iamcoe.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    # ── Main apps ─────────────────────────────────────
    location /HRSoft/ {
        proxy_pass http://127.0.0.1:8081/HRSoft/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /HRSoft { return 301 /HRSoft/; }

    location /AppraisalSoft_JDBC/ {
        proxy_pass http://127.0.0.1:8081/AppraisalSoft_JDBC/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /AppraisalSoft_JDBC { return 301 /AppraisalSoft_JDBC/; }

    location /BI_CSV/ {
        proxy_pass http://127.0.0.1:8081/BI_CSV/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /BI_CSV { return 301 /BI_CSV/; }

    location /TimeSheet_LDAP/ {
        proxy_pass http://127.0.0.1:8081/TimeSheet_LDAP/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /TimeSheet_LDAP { return 301 /TimeSheet_LDAP/; }

    location /HRSoft_WS/ {
        proxy_pass http://127.0.0.1:8081/HRSoft_WS/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /HRSoft_WS { return 301 /HRSoft_WS/; }

    location /identityiq/ {
        proxy_pass http://127.0.0.1:8082/identityiq/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
    }

    # ── Auth-protected Tomcat-hosted folders ──────────
    location /HRSoft_CSVExtract/ {
        proxy_pass http://127.0.0.1:8081/HRSoft_CSVExtract/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /HRSoft_CSVExtract { return 301 /HRSoft_CSVExtract/; }

    location /BI_CSVExtract/ {
        proxy_pass http://127.0.0.1:8081/BI_CSVExtract/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /BI_CSVExtract { return 301 /BI_CSVExtract/; }

    location /logs/ {
        proxy_pass http://127.0.0.1:8081/logs/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /logs { return 301 /logs/; }

    location /properties/ {
        proxy_pass http://127.0.0.1:8081/properties/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /properties { return 301 /properties/; }
}
EOF

sudo ln -sf /etc/nginx/sites-available/iamcoe.conf /etc/nginx/sites-enabled/iamcoe.conf
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl enable nginx && sudo systemctl reload nginx
echo "✅ nginx configured"

# ── 13. Final status ──────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  IAM COE Lab Setup Complete"
echo "============================================================"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "  📌 Main Apps (no login required):"
echo "     HRSoft:              https://$VM_IP/HRSoft/"
echo "     AppraisalSoft JDBC:  https://$VM_IP/AppraisalSoft_JDBC/"
echo "     BI CSV:              https://$VM_IP/BI_CSV/"
echo "     TimeSheet LDAP:      https://$VM_IP/TimeSheet_LDAP/"
echo "     HRSoft WS (feeds):   https://$VM_IP/HRSoft_WS/GetFeeds"
echo "     SailPoint IIQ:       https://$VM_IP/identityiq/"
echo ""
echo "  🔐 Protected folders (coelabuser / coeL@bPa\$\$):"
echo "     HRSoft CSV Extract:  https://$VM_IP/HRSoft_CSVExtract/"
echo "     BI CSV Extract:      https://$VM_IP/BI_CSVExtract/"
echo "     SailPoint Logs:      https://$VM_IP/logs/"
echo "     SailPoint Properties:https://$VM_IP/properties/"
echo ""
echo "  🛠  Admin tools:"
echo "     phpMyAdmin:          http://$VM_IP:8086  (root / I@mR00t)"
echo "     phpLDAPadmin:        http://$VM_IP:8080  (cn=admin,dc=iamcoe,dc=cloud / admin)"
echo ""
echo "  ⚠️  NOTE: SailPoint may still be building in the background if this is"
echo "     a fresh VM. Check: docker logs -f sailpoint"
echo "     It will be ready at https://$VM_IP/identityiq/ when done."
echo "     Default login: spadmin / admin"
echo "============================================================"
