require 'export_dsi_users_to_big_query'
require 'export_dsi_approvers_to_big_query'

class ExportDsiUsersToBigQueryJob < ApplicationJob
  queue_as :export_users

  def perform
    if Rails.env.production?
      ExportDsiUsersToBigQuery.new.run!
      ExportDsiApproversToBigQuery.new.run!
    end
  end
end
