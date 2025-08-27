#!/bin/bash 
set -e

# Required ENV variables (set in Coolify UI)
: "${SITE_NAME:?SITE_NAME env is required}"
: "${MARIADB_HOST:?MARIADB_HOST env is required}"
: "${REDIS_URL:?REDIS_URL env is required}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD env is required}"
: "${ADMIN_PASSWORD:?ADMIN_PASSWORD env is required}"

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "✅ Bench already exists, skipping init"
    cd frappe-bench
else
    echo "🚀 Creating new bench..."
    bench init --skip-redis-config-generation frappe-bench --version version-15
    cd frappe-bench

    # Use env vars instead of hardcoded values
    bench set-mariadb-host "$MARIADB_HOST"
    bench set-redis-cache-host "$REDIS_URL"
    bench set-redis-queue-host "$REDIS_URL"
    bench set-redis-socketio-host "$REDIS_URL"

    # Remove redis + watch from Procfile
    sed -i '/redis/d' ./Procfile
    sed -i '/watch/d' ./Procfile

    # Create site from ENV
    bench new-site "$SITE_NAME" \
        --force \
        --mariadb-root-password "$MYSQL_ROOT_PASSWORD" \
        --admin-password "$ADMIN_PASSWORD" \
        --no-mariadb-socket

    # Install CRM app if present
    if [ -d "/home/frappe/frappe-bench/apps/crm" ]; then
        bench --site "$SITE_NAME" install-app crm
    else
        echo "⚠️  CRM app not found, skipping installation"
    fi
    
    bench --site "$SITE_NAME" set-config developer_mode 1
    bench --site "$SITE_NAME" set-config mute_emails 1
    bench --site "$SITE_NAME" set-config server_script_enabled 1
    bench --site "$SITE_NAME" clear-cache
    bench use "$SITE_NAME"
fi

echo "▶️ Starting bench..."
bench start
