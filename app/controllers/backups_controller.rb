# app/controllers/backups_controller.rb
require "rake"

class BackupsController < ApplicationController
  before_action :authenticate_user!      # Devise JWT
  before_action :authorize_admin!

  # Load the Rake tasks once when the class is first referenced
  # (so you can call Rake::Task[...] safely)
  Rails.application.load_tasks

  # POST /backup
  def create
    # Re-enable & invoke your stockware:backup task
    Rake::Task["stockware:backup"].reenable
    Rake::Task["stockware:backup"].invoke

    render json: { message: "Backup kicked off" }, status: :accepted
  rescue => e
    # If anything goes wrong (pg_dump, tar, etc), return 500 + error message
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def authorize_admin!
    head :forbidden unless current_user.admin?
  end
end
