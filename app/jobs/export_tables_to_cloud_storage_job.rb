require 'export_tables_to_cloud_storage'

class ExportTablesToCloudStorageJob < ApplicationJob
  queue_as :export_tables

  def perform
    ExportTablesToCloudStorage.new.run!
  end
end
