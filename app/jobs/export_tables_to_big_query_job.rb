require "export_tables_to_big_query"

class ExportTablesToBigQueryJob < ActiveJob::Base
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    ExportTablesToBigQuery.new.run!
  end
end
