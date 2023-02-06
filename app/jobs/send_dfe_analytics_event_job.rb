class SendDfeAnalyticsEventJob < SendEventToDataWarehouseJob
  def perform(data)
    dfe_analytic_event = DfE::Analytics::Event.new
       .with_type(data.fetch(:type))
       .with_request_details(data.fetch(:request))
       .with_response_details(data.fetch(:response))
       .with_data(data.fetch(:data))

    DfE::Analytics::SendEvents.do([dfe_analytic_event])
  end
end
