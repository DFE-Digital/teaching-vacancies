require 'export_dsi_users_to_big_query'
require 'export_dsi_approvers_to_big_query'

class ExportDsiUsersToBigQueryJob < ApplicationJob
  queue_as :export_users

  def perform
    return if DisableExpensiveJobs.enabled?

    ExportDsiUsersToBigQuery.new.run!
    ExportDsiApproversToBigQuery.new.run!
  end
end
