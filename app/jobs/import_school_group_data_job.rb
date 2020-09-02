require 'import_school_group_data'

class ImportSchoolGroupDataJob < ApplicationJob
  queue_as :import_school_group_data

  def perform
    return if DisableExpensiveJobs.enabled?

    ImportSchoolGroupData.new.run!
  end
end
