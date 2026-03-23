#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
fi

ACTION=${1:-start}

case "$ACTION" in
  start)
    docker-compose -f docker-compose.yml up -d
    ;;
  stop)
    docker-compose -f docker-compose.yml stop
    ;;
  down)
    docker-compose -f docker-compose.yml down
    ;;
  restart)
    docker-compose -f docker-compose.yml restart
    ;;
  *)
    echo "Usage: $0 [start|stop|restart|down]" >&2
    exit 2
    ;;
esac
