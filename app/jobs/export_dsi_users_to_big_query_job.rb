require "export_dsi_users_to_big_query"
require "export_dsi_approvers_to_big_query"

class ExportDSIUsersToBigQueryJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    ExportDSIUsersToBigQuery.new.run!
    ExportDSIApproversToBigQuery.new.run!
  end
end
