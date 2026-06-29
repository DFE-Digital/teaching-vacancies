require "rails_helper"

RSpec.describe Publishers::DfeSignIn::Parsing do
  subject(:parser) { Class.new { include Publishers::DfeSignIn::Parsing }.new }

  let(:la_category_id) { Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:local_authority] }

  describe "#la_code" do
    context "when using the approvers API schema (capitalised keys)" do
      context "when the organisation is a local authority" do
        let(:user) do
          { "organisation" => { "Category" => la_category_id, "EstablishmentNumber" => "123" } }
        end

        it "returns the establishment number" do
          expect(parser.la_code(user)).to eq("123")
        end
      end

      context "when the organisation is not a local authority" do
        let(:user) do
          { "organisation" => { "Category" => "001", "EstablishmentNumber" => "123" } }
        end

        it "returns nil" do
          expect(parser.la_code(user)).to be_nil
        end
      end
    end

    context "when using the users API schema (lowercase keys)" do
      context "when the organisation is a local authority" do
        let(:user) do
          { "organisation" => { "category" => { "id" => la_category_id }, "establishmentNumber" => "456" } }
        end

        it "returns the establishment number" do
          expect(parser.la_code(user)).to eq("456")
        end
      end

      context "when the organisation is not a local authority" do
        let(:user) do
          { "organisation" => { "category" => { "id" => "001" }, "establishmentNumber" => "456" } }
        end

        it "returns nil" do
          expect(parser.la_code(user)).to be_nil
        end
      end
    end

    context "when the organisation key is missing" do
      let(:user) { {} }

      it "returns nil" do
        expect(parser.la_code(user)).to be_nil
      end
    end
  end
end
