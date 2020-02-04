require 'export_user_records_to_big_query'

class ExportUserRecordsToBigQueryJob < ApplicationJob
  queue_as :export_users

  def perform
    ExportUserRecordsToBigQuery.new.run!
  end
end
