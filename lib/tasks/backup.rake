# lib/tasks/backup.rake
require "dotenv/load"

namespace :stockware do
  desc "Backup PostgreSQL DB + ActiveStorage into backups/ (overwrites latest)"
  task backup: :environment do
    backups_dir     = Rails.root.join("backups")
    latest_dump     = backups_dir.join("stockware_latest.dump")
    latest_storage  = backups_dir.join("storage_latest.tgz")

    FileUtils.mkdir_p(backups_dir) unless Dir.exist?(backups_dir)

    puts "⏳ Dumping DB to #{latest_dump}..."
    unless system("pg_dump -Fc -d #{ENV.fetch('PGDATABASE')} > #{latest_dump}")
      abort "❌ pg_dump failed—see above for details."
    end

    puts "⏳ Archiving storage to #{latest_storage} (relative)…"
    Dir.chdir(Rails.root) do
      # this archives only the `storage/` folder, not the full absolute path
      abort("tar failed") unless system("tar czf #{latest_storage} storage")
    end

    puts "🎉 Backup complete: #{latest_dump} and #{latest_storage}"
  end
end
