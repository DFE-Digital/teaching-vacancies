class SendEventToDataWarehouseJob < ApplicationJob
  queue_as :low

  self.logger = ActiveSupport::TaggedLogging.new(Logger.new(IO::NULL))

  def perform(table_name, data)
    if ready_for_new_platform?(data.fetch(:type))
      dfe_analytic_event = DfE::Analytics::Event.new
        .with_type(data.fetch(:type))
        .with_data(data: data.fetch(:data))

      DfE::Analytics::SendEvents.do([dfe_analytic_event])
    end

    bq = Google::Cloud::Bigquery.new
    dataset = bq.dataset(Rails.configuration.big_query_dataset, skip_lookup: true)
    table = dataset.table(table_name, skip_lookup: true)

    table.insert(data)
  end

  def ready_for_new_platform?(type)
    allowed_types = DfE::Analytics::Event::EVENT_TYPES + DfE::Analytics.custom_events
    allowed_types.include?(type.to_s)
  end
end
