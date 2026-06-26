#!/bin/bash
set -e

echo "===== IAM COE Lab Setup ====="

# ── 0. Get VM IP ──────────────────────────────────────────────────────────────
VM_IP=$(curl -s ifconfig.me)
echo "🌍 VM IP: $VM_IP"

# ── 1. Install dependencies ───────────────────────────────────────────────────
echo "📦 Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose-plugin nginx git-lfs

sudo systemctl enable docker && sudo systemctl start docker
sudo usermod -aG docker $USER

git lfs install
git lfs pull

# ── 2. Create shared Docker network ──────────────────────────────────────────
echo "🌐 Creating Docker network..."
docker network create iam-coe-local-net 2>/dev/null || echo "Network already exists"

# ── 3. Create host folders ────────────────────────────────────────────────────
echo "📁 Creating host folders..."
sudo mkdir -p /opt/CSVFiles_HRSoft
sudo mkdir -p /opt/CSVFiles_BI_Uploaded
sudo mkdir -p /opt/sp_properties
sudo chmod 777 /opt/CSVFiles_HRSoft /opt/CSVFiles_BI_Uploaded /opt/sp_properties

# ── 4. Start DB server ────────────────────────────────────────────────────────
echo "🗄️ Starting DB server..."
cd ~/iam-coe-lab/db-server
docker compose up -d
echo "⏳ Waiting for MySQL to initialize..."
sleep 30

# ── 5. Start LDAP server ──────────────────────────────────────────────────────
echo "📂 Starting LDAP server..."
cd ~/iam-coe-lab/ldap-server
docker compose up -d

# ── 6. Start Apps server ──────────────────────────────────────────────────────
echo "🚀 Starting Apps server..."
cd ~/iam-coe-lab/apps-server
docker compose build tomcat
docker compose up -d
echo "⏳ Waiting for Tomcat to deploy WARs..."
sleep 40

# ── 7. WEB-INF for host-served folders ───────────────────────────────────────
echo "🔒 Creating WEB-INF security configs..."

sudo mkdir -p /opt/CSVFiles_HRSoft/WEB-INF
sudo tee /opt/CSVFiles_HRSoft/WEB-INF/web.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
         http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
  <display-name>HRSoft_CSVExtract</display-name>
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
    <realm-name>COE Lab - HRSoft CSV</realm-name>
  </login-config>
  <security-role>
    <role-name>coelab</role-name>
  </security-role>
</web-app>
EOF

sudo mkdir -p /opt/CSVFiles_BI_Uploaded/WEB-INF
sudo tee /opt/CSVFiles_BI_Uploaded/WEB-INF/web.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
         http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
  <display-name>BI_CSVExtract</display-name>
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
    <realm-name>COE Lab - BI CSV</realm-name>
  </login-config>
  <security-role>
    <role-name>coelab</role-name>
  </security-role>
</web-app>
EOF

# ── 8. Start SailPoint ────────────────────────────────────────────────────────
echo "⛵ Starting SailPoint..."
cd ~/iam-coe-lab/sailpoint
docker compose up -d
echo "⏳ Waiting for SailPoint to initialize (this takes ~2 mins)..."
sleep 120

# ── 9. Enable SailPoint file logging ─────────────────────────────────────────
echo "📋 Enabling SailPoint file logging..."
MOUNT2=$(docker volume inspect sailpoint_iiq_webapps --format '{{.Mountpoint}}' 2>/dev/null || echo "")
if [ -n "$MOUNT2" ]; then
  F="$MOUNT2/identityiq/WEB-INF/classes/log4j2.properties"
  if [ -f "$F" ]; then
    sudo cp "$F" "$F.bak"
    sudo tee -a "$F" > /dev/null << 'EOF'

# File appender added for /logs endpoint
appender.file.type=File
appender.file.name=file
appender.file.fileName=/opt/iiq/logs/sailpoint.log
appender.file.layout.type=PatternLayout
appender.file.layout.pattern=%d{ISO8601} %5p %t %c{4}:%L - %m%n
rootLogger.appenderRef.file.ref=file
EOF
    docker exec -u root sailpoint mkdir -p /opt/iiq/logs
    docker exec -u root sailpoint chmod 777 /opt/iiq/logs
    docker restart sailpoint
    sleep 30
    # Copy properties file to host exposed folder
    sudo cp "$F" /opt/sp_properties/log4j2.properties
    sudo chmod 644 /opt/sp_properties/log4j2.properties
    echo "✅ SailPoint logging enabled"
  fi
fi

# ── 10. Setup nginx ───────────────────────────────────────────────────────────
echo "🌐 Configuring nginx..."

# Generate self-signed SSL cert if not present
if [ ! -f /etc/nginx/ssl/iamcoe.crt ]; then
  sudo mkdir -p /etc/nginx/ssl
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/iamcoe.key \
    -out /etc/nginx/ssl/iamcoe.crt \
    -subj "/CN=$VM_IP"
  echo "✅ Self-signed SSL certificate created"
fi

sudo tee /etc/nginx/sites-available/iamcoe.conf > /dev/null << EOF
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

    location /identityiq/ {
        proxy_pass http://127.0.0.1:8082/identityiq/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /HRSoft_WS/ {
        proxy_pass http://127.0.0.1:8081/HRSoft_WS/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /HRSoft_WS { return 301 /HRSoft_WS/; }

    location /TimeSheet_LDAP/ {
        proxy_pass http://127.0.0.1:8081/TimeSheet_LDAP/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location = /TimeSheet_LDAP { return 301 /TimeSheet_LDAP/; }

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
}
EOF

sudo ln -sf /etc/nginx/sites-available/iamcoe.conf /etc/nginx/sites-enabled/iamcoe.conf
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl enable nginx && sudo systemctl reload nginx
echo "✅ nginx configured"

# ── 11. Final status ──────────────────────────────────────────────────────────
echo ""
echo "===== Setup Complete ====="
docker ps --format "table {{.Names}}\t{{.Status}}"
echo ""
echo "URLs:"
echo "  HRSoft:              https://$VM_IP/HRSoft/"
echo "  AppraisalSoft:       https://$VM_IP/AppraisalSoft_JDBC/"
echo "  BI CSV:              https://$VM_IP/BI_CSV/"
echo "  TimeSheet LDAP:      https://$VM_IP/TimeSheet_LDAP/"
echo "  HRSoft WS:           https://$VM_IP/HRSoft_WS/"
echo "  SailPoint IIQ:       https://$VM_IP/identityiq/"
echo "  Logs:                https://$VM_IP/logs/              (coelabuser / coeL@bPa\$\$)"
echo "  Properties:          https://$VM_IP/properties/        (coelabuser / coeL@bPa\$\$)"
echo "  HRSoft CSV Extract:  https://$VM_IP/HRSoft_CSVExtract/ (coelabuser / coeL@bPa\$\$)"
echo "  BI CSV Extract:      https://$VM_IP/BI_CSVExtract/     (coelabuser / coeL@bPa\$\$)"
