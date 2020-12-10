require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  describe "page_visited events" do
    it "triggers a `page_visited` event on a request" do
      expect { get :check }.to have_enqueued_job(SendEventToDataWarehouseJob).with(
        "events",
        hash_including(type: :page_visited, request_path: "/check"),
      )
    end
  end

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

  describe "#strip_nested_param_whitespaces" do
    let(:nested_field) { { array_field: %w[1 2], string_field: "   Buckle my shoe   " } }
    let(:test_form) { { array_field: %w[3 4], string_field: "   Knock on the door   ", nested_field: nested_field } }
    let(:params) { { test_form: test_form } }

    before do
      get :check, params: params
    end

    it "strips any string fields of trailing whitespaces" do
      expect(controller.request.params[:test_form][:string_field]).to eq "Knock on the door"
    end

    it "strips any nested string fields of trailing whitespaces" do
      expect(controller.request.params[:test_form][:nested_field][:string_field]).to eq "Buckle my shoe"
    end

    it "leaves the other fields and params unchanged" do
      expect(controller.request.params[:action]).to eq "check"
      expect(controller.request.params[:controller]).to eq "application"
      expect(controller.request.params[:test_form][:nested_field][:array_field]).to eq %w[1 2]
      expect(controller.request.params[:test_form][:array_field]).to eq %w[3 4]
    end
  end
end
