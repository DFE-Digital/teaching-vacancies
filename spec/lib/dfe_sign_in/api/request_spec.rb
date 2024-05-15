require "rails_helper"
require "dfe_sign_in/api/request"

RSpec.shared_examples "a DFE Sign In endpoint" do
  context "when the external response status is 500" do
    before { stub_api_response_with_external_error(1) }

    it "raises an external server error" do
      expect { subject.perform }.to raise_error(DfeSignIn::API::Request::ExternalServerError)
    end
  end

  context "when the response status is 403" do
    before { stub_api_response_with_forbidden_error(1) }

    it "raises an forbidden request error" do
      expect { subject.perform }.to raise_error(DfeSignIn::API::Request::ForbiddenRequestError)
    end
  end

  context "when the response status is unknown" do
    before do
      stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}#{api_path}?page=1&pageSize=#{page_size}")
        .to_return(body: "", status: 499)
    end
    it "raises an unknown response error" do
      expect { subject.perform }.to raise_error(DfeSignIn::API::Request::UnknownResponseError)
    end
  end

  context "when the response code is 200" do
    it "returns the users from the API" do
      stub_api_response_for_page(1)
      response = subject.perform

      expect(response).to eq(JSON.parse(response_file(1)))
    end

    context "when providing a different page number" do
      let(:page) { 2 }

      it "returns the approvers from the API for a given page " do
        stub_api_response_for_page(2)
        response = subject.perform

        expect(response).to eq(JSON.parse(response_file(2)))
        expect(response["page"]).to eq(2)
        expect(response["numberOfPages"]).to eq(2)
      end
    end

    it "sets a token in the header of the request" do
      freeze_time do
        expected_token = generate_jwt_token

        stub_api_response_for_page(1)
        subject.perform

        expect(a_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}#{api_path}?page=1&pageSize=#{page_size}")
          .with(headers: { "Authorization" => "Bearer #{expected_token}" }))
          .to have_been_made
      end
    end
  end

  def response_file(page)
    File.read(Rails.root.join(
                "spec",
                "fixtures",
                "dfe_sign_in_service_#{fixture_filename}_response_page_#{page}.json",
              ))
  end

  def stub_api_response_for_page(page)
    stub_request(:get,
                 "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}#{api_path}?page=#{page}&pageSize=#{page_size}")
      .to_return(body: response_file(page), status: 200)
  end

  def stub_api_response_with_external_error(page)
    stub_request(:get,
                 "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}#{api_path}?page=#{page}&pageSize=#{page_size}")
      .to_return(body: "", status: 500)
  end

  def stub_api_response_with_forbidden_error(page)
    stub_request(:get,
                 "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}#{api_path}?page=#{page}&pageSize=#{page_size}")
      .to_return(body: '{"success":false,"message":"jwt expired"}', status: 403)
  end

  def generate_jwt_token
    payload = {
      iss: "schooljobs",
      exp: (Time.current.getlocal + 60).to_i,
      aud: "signin.education.gov.uk",
    }

    JWT.encode(payload, ENV.fetch("DFE_SIGN_IN_PASSWORD", nil), "HS256")
  end
end

RSpec.describe DfeSignIn::API::Request do
  describe ".perform" do
    let(:page) { 1 }
    let(:page_size) { 275 }

    subject { described_class.new(api_path, page, page_size) }

    context "when requesting users" do
      let(:api_path) { "/users" }
      let(:fixture_filename) { "users" }

      it_behaves_like "a DFE Sign In endpoint"
    end

    context "when requesting users" do
      let(:api_path) { "/users/approvers" }
      let(:fixture_filename) { "approvers" }

      it_behaves_like "a DFE Sign In endpoint"
    end
  end
end
