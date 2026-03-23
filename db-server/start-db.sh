#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
fi

TYPE=${1:-${DB_TYPE:-mysql}}
ACTION=${2:-start}

case "$TYPE" in
  mysql)
    SERVICE=mysql
    ;;
  postgres)
    SERVICE=postgres
    ;;
  *)
    echo "Unsupported DB type: $TYPE" >&2
    exit 2
    ;;
esac

case "$ACTION" in
  start)
    docker-compose -f docker-compose.yml up -d $SERVICE
    ;;
  stop)
    docker-compose -f docker-compose.yml stop $SERVICE
    ;;
  restart)
    docker-compose -f docker-compose.yml restart $SERVICE
    ;;
  down)
    docker-compose -f docker-compose.yml down
    ;;
  init)
    ./init-db.sh "$TYPE"
    ;;
  *)
    echo "Usage: $0 [mysql|postgres] [start|stop|restart|down|init]" >&2
    exit 2
    ;;
esac
