require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def test_action
      head :ok
    end
  end

  before do
    routes.draw { get "test_action" => "anonymous#test_action" }
  end

  describe "page_visited events" do
    it "triggers a `page_visited` event on a request" do
      expect { get :test_action }.to have_enqueued_job(SendEventToDataWarehouseJob).with(
        "events",
        hash_including(type: :page_visited, request_path: "/test_action"),
      )
    end
  end

  describe "sets headers" do
    it "robots are asked not to index or to follow" do
      get :test_action
      expect(response.headers["X-Robots-Tag"]).to eq("noindex, nofollow")
    end
  end

  describe "#strip_empty_checkboxes" do
    controller do
      before_action { strip_empty_checkboxes(%i[nothing_to_remove_field array_field string_field], :test_form) }

      def strip_test_action
        head :ok
      end
    end

    before do
      routes.draw { get "strip_test_action" => "anonymous#strip_test_action" }

      get :strip_test_action, params: {
        test_form: {
          nothing_to_remove_field: %w[first_box second_box],
          array_field: ["first_box", ""],
          string_field: "",
        },
      }
    end

    it "removes empty checkboxes as expected" do
      expect(controller.params[:test_form][:nothing_to_remove_field]).to eql(%w[first_box second_box])
      expect(controller.params[:test_form][:array_field]).to eql(%w[first_box])
      expect(controller.params[:test_form][:string_field]).to eql("")
    end
  end

  describe "#strip_nested_param_whitespaces" do
    let(:nested_field) { { array_field: %w[1 2], string_field: "   Buckle my shoe   " } }
    let(:test_form) { { array_field: %w[3 4], string_field: "   Knock on the door   ", nested_field: nested_field } }
    let(:params) { { test_form: test_form } }

    before do
      get :test_action, params: params
    end

    it "strips any string fields of trailing whitespaces" do
      expect(controller.params[:test_form][:string_field]).to eq "Knock on the door"
    end

    it "strips any nested string fields of trailing whitespaces" do
      expect(controller.params[:test_form][:nested_field][:string_field]).to eq "Buckle my shoe"
    end

    it "leaves the other fields and params unchanged" do
      expect(controller.params[:action]).to eq "test_action"
      expect(controller.params[:controller]).to eq "anonymous"
      expect(controller.params[:test_form][:nested_field][:array_field]).to eq %w[1 2]
      expect(controller.params[:test_form][:array_field]).to eq %w[3 4]
    end
  end
end
