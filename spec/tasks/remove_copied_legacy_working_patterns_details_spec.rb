require "rails_helper"

RSpec.describe "vacancies:remove_copied_legacy_working_patterns_details" do
  let(:migration_date) { Date.new(2022, 8, 25) }
  let(:working_patterns_details) { "Legacy details" }

  let!(:vacancy) do
    create(:vacancy, created_at:, working_patterns:, full_time_details:, part_time_details:, working_patterns_details:)
  end

  RSpec.shared_examples "removes legacy working patterns details" do
    it "removes the legacy working patterns details" do
      expect { task.invoke }.to change { vacancy.reload.working_patterns_details }.from(working_patterns_details).to(nil)
    end
  end

  RSpec.shared_examples "does not remove legacy working patterns details" do
    it "does not remove the legacy working patterns details" do
      expect { task.invoke }.not_to(change { vacancy.reload.working_patterns_details })
    end
  end

  context "with a vacancy created post-migration date" do
    let(:created_at) { migration_date + 1.day }

    context "with full_time_details and part_time_details" do
      let(:working_patterns) { %w[full_time part_time] }
      let(:full_time_details) { "Full time details" }
      let(:part_time_details) { "Part time details" }

      include_examples "removes legacy working patterns details"
    end

    context "without full_time_details and part_time_details" do
      let(:working_patterns) { [] }
      let(:full_time_details) { "" }
      let(:part_time_details) { "" }

      include_examples "does not remove legacy working patterns details"
    end

    context "with only full_time_details" do
      let(:working_patterns) { %w[full_time] }
      let(:full_time_details) { "Full time details" }
      let(:part_time_details) { "" }

      include_examples "removes legacy working patterns details"
    end

    context "with only part_time_details" do
      let(:working_patterns) { %w[part_time] }
      let(:full_time_details) { "" }
      let(:part_time_details) { "Part time details" }

      include_examples "removes legacy working patterns details"
    end
  end

  context "with a vacancy created pre-migration date" do
    let(:created_at) { migration_date - 1.day }

    context "with full_time_details and part_time_details" do
      let(:working_patterns) { %w[full_time part_time] }
      let(:full_time_details) { "Full time details" }
      let(:part_time_details) { "Part time details" }

      include_examples "does not remove legacy working patterns details"
    end

    context "without full_time_details and part_time_details" do
      let(:working_patterns) { [] }
      let(:full_time_details) { "" }
      let(:part_time_details) { "" }

      include_examples "does not remove legacy working patterns details"
    end

    context "with only full_time_details" do
      let(:working_patterns) { %w[full_time] }
      let(:full_time_details) { "Full time details" }
      let(:part_time_details) { "" }

      include_examples "does not remove legacy working patterns details"
    end

    context "with only part_time_details" do
      let(:working_patterns) { %w[part_time] }
      let(:full_time_details) { "" }
      let(:part_time_details) { "Part time details" }

      include_examples "does not remove legacy working patterns details"
    end
  end
end
