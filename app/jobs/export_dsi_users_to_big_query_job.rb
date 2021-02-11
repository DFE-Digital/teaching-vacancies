require "export_dsi_users_to_big_query"
require "export_dsi_approvers_to_big_query"

class ExportDsiUsersToBigQueryJob < ActiveJob::Base
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    ExportDsiUsersToBigQuery.new.run!
    ExportDsiApproversToBigQuery.new.run!
  end
end
