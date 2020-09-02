require 'update_school_data'

class UpdateSchoolsDataFromSourceJob < ApplicationJob
  queue_as :import_school_data

  def perform
    return if DisableExpensiveJobs.enabled?

    UpdateSchoolData.new.run!
  end
end
