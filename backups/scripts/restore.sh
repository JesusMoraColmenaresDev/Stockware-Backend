#!/usr/bin/env bash
set -euo pipefail

# ─── 1) cd into Rails root ───────────────────────────────────────────────────
cd "$(dirname "$0")/../.."

# ─── 2) load .env vars ───────────────────────────────────────────────────────
set -a
[ -f .env ] && . .env
set +a

# ─── 3) drop & recreate the database ─────────────────────────────────────────
echo "🔄 Dropping database ${PGDATABASE} if exists..."
dropdb --if-exists "$PGDATABASE"

echo "🔄 Creating database ${PGDATABASE}..."
createdb "$PGDATABASE"

# ─── 4) restore schema & data ─────────────────────────────────────────────────
echo "🔄 Restoring data from backups/stockware_latest.dump..."
pg_restore \
  --no-owner \
  --dbname="$PGDATABASE" \
  backups/stockware_latest.dump

# ─── 5) clear & restore ActiveStorage ────────────────────────────────────────
echo "🔄 Clearing out storage/ contents..."
# remove everything (including hidden), but keep the storage/ folder itself
find storage -mindepth 1 -delete

echo "🔄 Extracting storage files into storage/ (stripping one leading path)..."
# -C storage → extract into storage/
# --strip-components=1 → remove the initial 'storage/' directory level inside the tar
tar xzf backups/storage_latest.tgz -C storage --strip-components=1 # Si quisieramos que sobreescriba archivos existentes, podríamos usar --overwrite

echo "✅ Restore complete!"
