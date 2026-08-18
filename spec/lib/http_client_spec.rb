require "rails_helper"

RSpec.describe HttpClient do
  describe ".connection" do
    it "returns a Faraday connection configured with the retry middleware" do
      connection = described_class.connection

      expect(connection).to be_a(Faraday::Connection)
      retry_handler = connection.builder.handlers.find { |handler| handler.klass == Faraday::Retry::Middleware }
      expect(retry_handler).to be_present
    end

    it "defaults to 3 retries with an exponential backoff" do
      connection = described_class.connection
      retry_handler = connection.builder.handlers.find { |handler| handler.klass == Faraday::Retry::Middleware }

      options = retry_handler.instance_variable_get(:@args).first
      expect(options[:max]).to eq(3)
      expect(options[:backoff_factor]).to eq(2)
    end

    it "allows callers to override the retry options" do
      connection = described_class.connection(retry_options: { max: 1 })
      retry_handler = connection.builder.handlers.find { |handler| handler.klass == Faraday::Retry::Middleware }

      options = retry_handler.instance_variable_get(:@args).first
      expect(options[:max]).to eq(1)
    end

    it "passes through other Faraday connection options, such as a base url" do
      connection = described_class.connection(url: "https://example.com")

      expect(connection.url_prefix.to_s).to eq("https://example.com/")
    end
  end

  describe "retry behaviour" do
    let(:url) { "http://example.com/flaky" }

    it "retries on a retryable status and returns the eventual successful response" do
      stub_request(:get, url)
        .to_return({ status: 503 }, { status: 503 }, { status: 200, body: "ok" })

      response = described_class.connection(retry_options: { interval: 0 }).get(url)

      expect(response.status).to eq(200)
      expect(response.body).to eq("ok")
      expect(WebMock).to have_requested(:get, url).times(3)
    end

    it "gives up after the max number of retries and returns the last failing response" do
      stub_request(:get, url).to_return(status: 503)

      response = described_class.connection(retry_options: { max: 2, interval: 0 }).get(url)

      expect(response.status).to eq(503)
      expect(WebMock).to have_requested(:get, url).times(3)
    end

    it "retries connection failures" do
      stub_request(:get, url).to_raise(Faraday::ConnectionFailed).then.to_return(status: 200, body: "ok")

      response = described_class.connection(retry_options: { interval: 0 }).get(url)

      expect(response.status).to eq(200)
      expect(WebMock).to have_requested(:get, url).times(2)
    end
  end
end
