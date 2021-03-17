class SendEntityImportedEventsToDataWarehouseJob < ApplicationJob
  TABLE_NAME = "events".freeze

  queue_as :low

  self.logger = nil

  def perform
    bq = Google::Cloud::Bigquery.new
    dataset = bq.dataset(ENV.fetch("BIG_QUERY_DATASET"), skip_lookup: true)
    bq_table = dataset.table(TABLE_NAME, skip_lookup: true)

    ApplicationRecord.connection.tables.each do |db_table|
      next unless Rails.configuration.analytics.key?(db_table.to_sym)

      Rails.logger.info("sending #{db_table.camelize.singularize.constantize.count} #{db_table} entity_imported events to bigquery")
      db_table.camelize.singularize.constantize.find_in_batches(batch_size: 100) do |batch|
        bq_table.insert(
          batch.map do |record|
            {
              type: :entity_imported,
              occurred_at: occurred_at(record),
              data: record.send(:event_data).map { |key, value| { key: key.to_s, value: formatted_value(value) } },
            }
          end,
        )
      end
    end
  end

  private

  def formatted_value(value)
    return value if value.is_a?(Float) || value.is_a?(Integer)

    value.respond_to?(:keys) ? value.to_json : value&.to_s
  end

  def occurred_at(data)
    time = if data[:created_at].present?
             data[:created_at]
           else
             Time.now.utc
           end
    time.iso8601(6)
  end
end
