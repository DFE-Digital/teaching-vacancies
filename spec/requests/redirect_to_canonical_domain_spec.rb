require "rails_helper"

RSpec.describe "Redirect to canonical domain" do
  let(:headers) { { "Host" => domain } }

  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
  end

  context "when request.host_with_port is different to the canonical domain" do
    let(:domain) { "DIFFERENT_DOMAIN" }

    it "redirects to the canonical domain" do
      get "/", headers: headers

      expect(response.status).to eq(301)

      domain_minus_port = DOMAIN.split(":").first
      expect(response.location).to eq("http://#{domain_minus_port}/")
    end
  end

  context "when request.host_with_port is already the canonical DOMAIN" do
    let(:domain) { DOMAIN }

    it "does not redirect" do
      get "/", headers: headers

      expect(response.status).to eq(200)
    end
  end
end
