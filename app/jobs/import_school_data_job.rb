require 'organisation_import/import_school_data'

class ImportSchoolDataJob < ApplicationJob
  queue_as :import_school_data

  def perform
    return if DisableExpensiveJobs.enabled?

    ImportSchoolData.new.run!
  end
end
