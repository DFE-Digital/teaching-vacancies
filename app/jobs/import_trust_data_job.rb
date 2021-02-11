require "organisation_import/import_trust_data"

class ImportTrustDataJob < ActiveJob::Base
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    ImportTrustData.new.run!
  end
end
