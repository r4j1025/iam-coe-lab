#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
fi

TYPE=${1:-${DB_TYPE:-mysql}}

case "$TYPE" in
  mysql)
    CONTAINER_NAME=${MYSQL_CONTAINER_NAME:-mysql_db}
    echo "Initializing MySQL inside container: $CONTAINER_NAME"
    docker exec -i "$CONTAINER_NAME" mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS \\`${MYSQL_DATABASE}\\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \\`${MYSQL_DATABASE}\\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL
    ;;
  postgres)
    CONTAINER_NAME=${POSTGRES_CONTAINER_NAME:-postgres_db}
    echo "Initializing Postgres inside container: $CONTAINER_NAME"
    docker exec -i "$CONTAINER_NAME" psql -U "${POSTGRES_USER}" -d "postgres" <<SQL
DO
\$\$BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '${POSTGRES_DB}') THEN
      PERFORM pg_database_create('${POSTGRES_DB}');
   END IF;
END
\$\$;
CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE "${POSTGRES_DB}" TO ${POSTGRES_USER};
SQL
    ;;
  *)
    echo "Unsupported DB type: $TYPE" >&2
    exit 2
    ;;
esac
