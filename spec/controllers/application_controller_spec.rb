require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  describe "#redirect_to_domain" do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      stub_const("DOMAIN", "localhost")
      @request.host = fake_domain
    end

    context "when request.host_with_port is different to DOMAIN" do
      let(:fake_domain) { "DIFFERENT_DOMAIN" }

      it "redirects to DOMAIN" do
        get :check
        expect(response.location).to eql("http://#{DOMAIN}/check")
        expect(response.status).to eql(301)
      end
    end

    context "when request.host_with_port is DOMAIN" do
      let(:fake_domain) { DOMAIN }

      it "does not redirect to DOMAIN" do
        get :check
        expect(response.status).to eql(200)
      end
    end
  end

  describe "routing" do
    it "check endpoint is publically accessible" do
      expect(get: "/check").to route_to(controller: "application", action: "check")
    end
  end

  describe "#request_ip" do
    it "returns the anonymized IP with the last octet zero padded" do
      expect(controller.request_ip).to eql("0.0.0.0")
    end

    context "when the IP is at the max range" do
      it "returns the anonymized IP with the last octet zero padded" do
        allow_any_instance_of(ActionController::TestRequest)
          .to receive(:remote_ip)
          .and_return("255.255.255.255")
        expect(controller.request_ip).to eql("255.255.255.0")
      end
    end
  end

  describe "#check_staging_auth" do
    context "when we want to authenticate" do
      before(:each) do
        allow(controller).to receive(:authenticate?).and_return(true)
      end

      it "passes information to ActionController to decide" do
        expect(controller).to receive(:authenticate_or_request_with_http_basic)
        controller.check_staging_auth
      end
    end

    context "when we do NOT want to authenticate" do
      before(:each) do
        allow(controller).to receive(:authenticate?).and_return(false)
      end

      it "skips the authentication call" do
        expect(controller).to_not receive(:authenticate_or_request_with_http_basic)
        controller.check_staging_auth
      end
    end
  end

  describe "#authenticate?" do
    context "when in test" do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new("test"))
      end

      it "returns false" do
        expect(controller.authenticate?).to eq(false)
      end
    end

    context "when in development" do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new("development"))
      end

      it "returns false" do
        expect(controller.authenticate?).to eq(false)
      end
    end

    context "when in staging" do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new("staging"))
      end

      it "returns true" do
        expect(controller.authenticate?).to eq(true)
      end
    end

    context "when in production" do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new("production"))
      end

      it "returns true" do
        expect(controller.authenticate?).to eq(false)
      end
    end
  end

  describe "sets headers" do
    it "robots are asked not to index or to follow" do
      get :check
      expect(response.headers["X-Robots-Tag"]).to eq("noindex, nofollow")
    end
  end

  describe "#strip_empty_checkboxes" do
    context "when the checkbox value is an Array" do
      let(:params) do
        { test_form: { test_field: checkboxes } }
      end

      before do
        allow(controller).to receive(:params).and_return(params)
      end

      context "no empty checkboxes added by GOVUKDesignSystemFormBuilder" do
        let(:checkboxes) { %w[first_box second_box] }

        it "removes nothing from the array" do
          subject.strip_empty_checkboxes(%i[test_field], :test_form)
          expect(controller.params[:test_form][:test_field]).to eql(checkboxes)
        end
      end

      context "empty checkbox added by GOVUKDesignSystemFormBuilder" do
        let(:checkboxes) { ["first_box", "second_box", ""] }
        let(:stripped_checkboxes) { %w[first_box second_box] }

        it "removes empty checkbox from the array" do
          subject.strip_empty_checkboxes(%i[test_field], :test_form)
          expect(controller.params[:test_form][:test_field]).to eql(stripped_checkboxes)
        end
      end
    end

    context "when the checkbox value is a String" do
      let(:params) do
        { test_form: { array_field: ["first_box", ""], string_field: "" } }
      end

      before do
        allow(controller).to receive(:params).and_return(params)
      end

      it "removes empty checkbox from the array without error" do
        subject.strip_empty_checkboxes(%i[array_field string_field], :test_form)
        expect(controller.params[:test_form][:array_field]).to eql(%w[first_box])
        expect(controller.params[:test_form][:string_field]).to eql("")
      end
    end
  end
end
