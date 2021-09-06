class SendFeedbackToBigQueryJob < ApplicationJob
  TABLE_NAME = "feedbacks".freeze
  BATCH_SIZE = 100

  queue_as :low

  def perform
    bq = Google::Cloud::Bigquery.new
    dataset = bq.dataset(Rails.configuration.big_query_dataset, skip_lookup: true)
    bq_table = dataset.table(TABLE_NAME, skip_lookup: true)

    Rails.logger.info("sending #{Feedback.where(exported_to_bigquery: false).count} new feedback events to bigquery")

    Feedback.where(exported_to_bigquery: false).find_in_batches(batch_size: BATCH_SIZE) do |batch|
      bq_table.insert(
        batch.map do |record|
          {
            type: record.feedback_type,
            occurred_at: record.created_at,
            data: record.attributes_except_ciphertext.map do |key, value|
                    { key: key.to_s, value: formatted_value(value) }
                  end,
          }
        end,
      )

      batch.each { |record| record.toggle!(:exported_to_bigquery) }
    end
  end

  private

  def formatted_value(value)
    return value if value.is_a?(Float) || value.is_a?(Integer)

    value.respond_to?(:keys) ? value.to_json : value&.to_s
  end
end
