class BackupJob < ApplicationJob
  queue_as :default

  def perform
    Rake::Task["stockware:backup"].reenable
    Rake::Task["stockware:backup"].invoke
  end
end
