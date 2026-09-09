# This is loaded correctly by Zeitwerk due to a custom inflection in config/inflections.rb
class ExportDSIApproversToBigQueryJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableIntegrations.enabled?

    Publishers::DfeSignIn::BigQueryExport::Approvers.new.call
  end
end
