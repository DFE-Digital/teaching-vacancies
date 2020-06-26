require 'import_school_group_data'

class ImportSchoolGroupDataJob < ApplicationJob
  queue_as :import_school_group_data

  def perform
    ImportSchoolGroupData.new.run!
  end
end
