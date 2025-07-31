#!/usr/bin/env bash
set -euo pipefail

# ─── 1) Move into your Rails app root ───────────────────────────────────────
cd "$(dirname "$0")/../.."

# ─── 2) Load .env into environment ────────────────────────────────────────
# This exports every VAR=VALUE line in .env so $PGDATABASE, $PGUSER, etc. exist
set -a
[ -f .env ] && . .env
set +a

# ─── 3) Drop & recreate the database ──────────────────────────────────────
echo "🔄 Dropping database ${PGDATABASE}..."
rails db:drop db:create

# ─── 4) Restore from latest dump ──────────────────────────────────────────
echo "🔄 Restoring database from backups/stockware_latest.dump..."
pg_restore \
  --no-owner \
  --clean \
  --dbname="$PGDATABASE" \
  backups/stockware_latest.dump

# ─── 5) Unpack ActiveStorage ─────────────────────────────────────────────
echo "🔄 Restoring ActiveStorage from backups/storage_latest.tgz..."
tar xzf backups/storage_latest.tgz -C .

echo "✅ Restore complete."
