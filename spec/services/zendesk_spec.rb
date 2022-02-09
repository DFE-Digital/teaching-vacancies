require "rails_helper"

RSpec.describe Zendesk, zendesk: true do
  subject(:service) { described_class }

  let(:client) { double(ZendeskAPI::Client) }
  let(:config) { double }

  before do
    allow(ZendeskAPI::Client).to receive(:new)
      .and_return(client)
      .and_yield(config)

    allow(config).to receive(:url=)
    allow(config).to receive(:username=)
    allow(config).to receive(:token=)
  end

  describe ".create_request!(name:, email_address:, subject:, comment:, attachments: [])" do
    let(:attachments) { [] }
    let(:comment) { "Help!" }
    let(:email_address) { "test@example.com" }
    let(:name) { "A User" }
    let(:subject) { "Some page" }

    let(:kwargs) do
      {
        attachments: attachments,
        comment: comment,
        email_address: email_address,
        name: name,
        subject: subject,
      }
    end

    let(:requests) { double(create!: nil) }
    let(:uploads) { double(create!: nil) }

    before do
      allow(client).to receive(:requests).and_return(requests)
      allow(client).to receive(:uploads).and_return(uploads)
    end

    it "uses the end user's email address as the API username" do
      service.create_request!(**kwargs)
      expect(config).to have_received(:username=).with(email_address)
    end

    it "creates a formatted request" do
      service.create_request!(**kwargs)
      expect(requests).to have_received(:create!).with(
        requester: {
          name: name,
          email: email_address,
        },
        subject: "[Support request] #{subject}",
        comment: {
          body: comment,
          uploads: [],
        },
      )
    end

    context "with attachments" do
      let(:attachments) do
        [file]
      end

      let(:file) { double }
      let(:upload_id) { SecureRandom.uuid }
      let(:upload) { double(id: upload_id) }

      it "uploads the attachments and assigns them to the comment" do
        expect(uploads).to receive(:create!)
          .with(file: file).and_return(upload)

        service.create_request!(**kwargs)

        expect(requests).to have_received(:create!).with(
          hash_including(
            comment: hash_including(uploads: [upload_id]),
          ),
        )
      end
    end

    describe "client configuration" do
      let(:api_key) { SecureRandom.uuid }

      around do |example|
        with_env("ZENDESK_API_KEY" => api_key) do
          example.run
        end
      end

      it "sets the URL" do
        service.create_request!(**kwargs)
        expect(config).to have_received(:url=)
          .with("https://becomingateacher.zendesk.com/api/v2")
      end

      it "sets the end user's email address" do
        service.create_request!(**kwargs)
        expect(config).to have_received(:username=).with(email_address)
      end

      it "sets the API token" do
        service.create_request!(**kwargs)
        expect(config).to have_received(:token=).with(api_key)
      end

      context "if the key is not set" do
        let(:api_key) { nil }

        it "raises a configuration error" do
          expect {
            service.create_request!(**kwargs)
          }.to raise_error(Zendesk::ConfigurationError)
        end
      end
    end
  end
end
