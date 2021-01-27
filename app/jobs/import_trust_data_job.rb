require "organisation_import/import_trust_data"

class ImportTrustDataJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    ImportTrustData.new.run!
  end
end
