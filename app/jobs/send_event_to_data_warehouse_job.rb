class SendEventToDataWarehouseJob < ApplicationJob
  queue_as :send_event_to_data_warehouse

  # Do not log that this job has been enqueued (as it produces at least one superfluous log per request)
  self.logger = nil

  def perform(table_name, data)
    bq = Google::Cloud::Bigquery.new
    dataset = bq.dataset(ENV.fetch("BIG_QUERY_DATASET"), skip_lookup: true)
    table = dataset.table(table_name, skip_lookup: true)

    table.insert(data)
  end
end
