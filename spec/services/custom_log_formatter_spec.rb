require "rails_helper"

RSpec.describe CustomLogFormatter do
  subject(:formatter) { described_class.new }

  let(:appender) { SemanticLogger::Appender::IO.new($stdout) }

  def build_log(message: "A log message", payload: nil)
    SemanticLogger::Log.new("Test", :warn).tap do |log|
      log.message = message
      log.payload = payload
    end
  end

  it "returns JSON for logs without a payload" do
    output = formatter.call(build_log, appender)

    expect(JSON.parse(output)).to include("message" => "A log message", "level" => "warn")
  end

  it "redacts the subject and to fields from the payload" do
    output = formatter.call(build_log(payload: { subject: "Sensitive subject", to: "someone@example.com", other: "value" }), appender)

    expect(JSON.parse(output)["payload"]).to eq("subject" => "[REDACTED]", "to" => "[REDACTED]", "other" => "value")
  end

  it "leaves payloads without subject or to fields unchanged" do
    output = formatter.call(build_log(payload: { other: "value" }), appender)

    expect(JSON.parse(output)["payload"]).to eq("other" => "value")
  end
end
