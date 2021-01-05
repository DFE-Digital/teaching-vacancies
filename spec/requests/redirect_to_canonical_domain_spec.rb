require "rails_helper"

RSpec.describe "Redirect to canonical domain", type: :request do
  let(:headers) { { "Host" => domain } }

  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
    stub_const("DOMAIN", "localhost")
  end

  context "when request.host_with_port is different to the canonical domain" do
    let(:domain) { "DIFFERENT_DOMAIN" }

    it "redirects to the canonical domain" do
      get "/", headers: headers

      expect(response.location).to eql("http://#{DOMAIN}/")
      expect(response.status).to eql(301)
    end
  end

  context "when request.host_with_port is already the canonical DOMAIN" do
    let(:domain) { DOMAIN }

    it "does not redirect" do
      get "/", headers: headers

      expect(response.status).to eql(200)
    end
  end
end
