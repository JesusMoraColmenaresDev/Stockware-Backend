#!/usr/bin/env bash
set -euo pipefail

# Navigate to your Rails project root (adjust if this script lives elsewhere)
cd "$(dirname "$0")/../.."  

echo "🔄 Dropping and recreating database..."
# Use dotenv to load your DB credentials, then drop & recreate
dotenv rails db:drop db:create

echo "🔄 Restoring database from latest dump..."
dotenv pg_restore \
  --no-owner \
  --clean \
  --dbname="${PGDATABASE}" \
  backups/stockware_latest.dump

echo "🔄 Restoring ActiveStorage from latest archive..."
tar xzf backups/storage_latest.tgz -C .

echo "✅ Restore complete."
