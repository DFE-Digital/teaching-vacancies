require "rails_helper"

RSpec.describe ApplicationRecord, type: :model do
  describe "#event_data" do
    context "when model is included in analytics.yml and has fields to anonymise" do
      let(:model) { build(:publisher) }

      let(:anonymised_data) do
        model.attributes.merge(table_name: "publishers",
                               "oid" => StringAnonymiser.new(model.oid).to_s,
                               "email" => StringAnonymiser.new(model.email).to_s,
                               "given_name" => StringAnonymiser.new(model.given_name).to_s,
                               "family_name" => StringAnonymiser.new(model.family_name).to_s)
      end

      it "anonymises data" do
        expect(model.send(:event_data)).to eq(anonymised_data)
      end
    end
  end
end
