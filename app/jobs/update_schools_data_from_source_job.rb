require 'update_school_data'

class UpdateSchoolsDataFromSourceJob < ApplicationJob
  queue_as :import_school_data

  def perform
    UpdateSchoolData.new.run! if Rails.env.production?
  end
end
