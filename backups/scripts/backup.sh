dotenv bash -c '
  # 1) Database dump (custom format)
  pg_dump -Fc > backups/stockware_latest.dump

  # 2) Archive ActiveStorage local files
  tar czf backups/storage_latest.tgz storage/
'