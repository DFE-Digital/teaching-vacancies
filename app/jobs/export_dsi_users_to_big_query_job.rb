class ExportDSIUsersToBigQueryJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    Publishers::DfeSignIn::BigQueryExport::Users.new.call
    Publishers::DfeSignIn::BigQueryExport::Approvers.new.call
  end
end
