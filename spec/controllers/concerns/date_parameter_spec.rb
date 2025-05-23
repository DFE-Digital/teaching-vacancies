require "rails_helper"

RSpec.describe DateParameter do
  let(:controller_class) do
    Class.new(ApplicationController) do
      include DateParameter
      date_param :user_birth_date

      def initialize(params = {})
        super()
        @params = params
      end
      attr_accessor :params

      private

      def user_birth_date
        %i[user birth_date]
      end
    end
  end

  let(:params) { {} }
  let(:controller) { controller_class.new(params) }

  it "registers the before_action callback" do
    callbacks = controller_class._process_action_callbacks
    callback_names = callbacks.map(&:filter)

    expect(callback_names).to include(:parse_user_birth_date)
  end

  describe ".date_param" do
    context "when date parameters are present" do
      let(:params) do
        {
          user: {
            "birth_date(1i)" => "2023",
            "birth_date(2i)" => "12",
            "birth_date(3i)" => "25",
            other_field: "value",
          },
        }
      end

      it "creates a filter method" do
        expect(controller).to respond_to(:parse_user_birth_date)
      end

      it "parses date parameters correctly" do
        controller.send(:parse_user_birth_date)

        expect(params[:user][:birth_date]).to eq("2023-12-25")
        expect(params[:user]).not_to have_key("birth_date(1i)")
        expect(params[:user]).not_to have_key("birth_date(2i)")
        expect(params[:user]).not_to have_key("birth_date(3i)")
        expect(params[:user][:other_field]).to eq("value")
      end
    end

    [nil, {}, { name: "John Doe", email: "john@example.com" }].each do |test_case|
      context "when hash[:user] is #{test_case}" do
        let(:params) { { user: test_case } }

        it "does not modify params" do
          original_params = params.dup
          controller.send(:parse_user_birth_date)

          expect(params).to eq(original_params)
        end
      end
    end

    context "when only some date parameters are present" do
      let(:params) do
        {
          user: {
            "birth_date(1i)" => "2023",
            "birth_date(2i)" => "12",
            # missing birth_date(3i)
          },
        }
      end

      it "still processes available parameters" do
        controller.send(:parse_user_birth_date)

        expect(params[:user][:birth_date]).to eq("2023-12-")
        expect(params[:user]).not_to have_key("birth_date(1i)")
        expect(params[:user]).not_to have_key("birth_date(2i)")
        expect(params[:user]).not_to have_key("birth_date(3i)")
      end
    end

    context "when nested path does not exist" do
      it "does not raise an error" do
        expect { controller.send(:parse_user_birth_date) }.not_to raise_error
      end
    end
  end
end
