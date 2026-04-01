#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
fi

CONTAINER_NAME=${MYSQL_CONTAINER_NAME:-mysql_db}
SQL_DIR="$ROOT_DIR/conf"

echo "Initializing MySQL inside container: $CONTAINER_NAME"
docker exec -i "$CONTAINER_NAME" mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

shopt -s nullglob
sql_files=("$SQL_DIR"/*.sql)
if [ "${#sql_files[@]}" -gt 0 ]; then
  echo "Applying SQL files from $SQL_DIR"
  for sql_file in "${sql_files[@]}"; do
    echo "Running $(basename "$sql_file")"
    docker exec -i "$CONTAINER_NAME" mysql -u root -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" < "$sql_file"
  done
else
  echo "No SQL files found in $SQL_DIR"
fi
shopt -u nullglob
