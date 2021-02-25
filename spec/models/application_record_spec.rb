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

    context "when model needs to anonymise an array field" do
      let(:model) { create(:publisher_preference, managed_school_ids: %w[id1 id2]) }

      let(:anonymised_data) do
        model.attributes.merge(table_name: "publisher_preferences",
                               "id" => StringAnonymiser.new(model.id).to_s,
                               "publisher_id" => StringAnonymiser.new(model.publisher_id).to_s,
                               "school_group_id" => StringAnonymiser.new(model.school_group_id).to_s,
                               "managed_school_ids" => [StringAnonymiser.new("id1").to_s, StringAnonymiser.new("id2").to_s])
      end

      it "anonymises data" do
        expect(model.send(:event_data)).to eq(anonymised_data)
      end
    end
  end
end
