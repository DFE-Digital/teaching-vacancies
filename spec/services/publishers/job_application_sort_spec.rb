require "rails_helper"

RSpec.describe Publishers::JobApplicationSort do
  subject { described_class.new.update(sort_by: sort_by) }

  describe "#by_db_column?" do
    context "when sorting by last_name" do
      let(:sort_by) { "last_name" }

      it { is_expected.not_to be_by_db_column }
    end

    context "when sorting by submitted_at" do
      let(:sort_by) { "submitted_at" }

      it { is_expected.to be_by_db_column }
    end
  end
end
