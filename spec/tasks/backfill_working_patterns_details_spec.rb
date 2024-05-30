require "rails_helper"

RSpec.describe "vacancies:backfill_working_patterns_details" do
  let(:migration_date) { Date.new(2022, 8, 25) }
  let(:full_time_details) { "Full time details" }
  let(:part_time_details) { "Part time details" }
  let(:working_patterns_details) { nil }

  let!(:vacancy) do
    create(:vacancy, created_at:, working_patterns:, full_time_details:, part_time_details:, working_patterns_details:)
  end

  RSpec.shared_examples "does not backfill working_patterns_details field" do
    it "does not backfill working_patterns_details field" do
      expect { task.invoke }.not_to(change { vacancy.reload.working_patterns_details })
    end
  end

  context "with a vacancy created post-migration date" do
    let(:created_at) { migration_date + 1.day }

    context "with full_time_details and part_time_details" do
      let(:working_patterns) { %w[full_time part_time] }
      let(:full_time_details) { "36 hours" }
      let(:part_time_details) { "20 hours" }

      it "combines the full and part time working patterns details into the working_patterns_details field" do
        expect { task.invoke }.to change { vacancy.reload.working_patterns_details }
                              .from(nil)
                              .to("Full time 36 hours. Part time 20 hours")
      end

      context "when the full_time_details ends with a period" do
        let(:full_time_details) { "36 hours." }

        it "doesn't add an extra period to the working_patterns_details field" do
          expect { task.invoke }.to change { vacancy.reload.working_patterns_details }
                                .from(nil)
                                .to("Full time 36 hours. Part time 20 hours")
        end
      end

      context "when the working_patterns_details field already has a value" do
        let(:working_patterns_details) { "Full time 40 hours" }

        include_examples "does not backfill working_patterns_details field"
      end
    end

    context "without full_time_details and part_time_details" do
      let(:working_patterns) { [] }
      let(:full_time_details) { "" }
      let(:part_time_details) { "" }

      include_examples "does not backfill working_patterns_details field"
    end

    context "with only full_time_details" do
      let(:working_patterns) { %w[full_time] }
      let(:full_time_details) { "36 hours" }
      let(:part_time_details) { "" }

      it "backfills the working_patterns_details field with the full time working patterns details" do
        expect { task.invoke }.to change { vacancy.reload.working_patterns_details }.from(nil).to("36 hours")
      end
    end

    context "with only part_time_details" do
      let(:working_patterns) { %w[part_time] }
      let(:full_time_details) { "" }
      let(:part_time_details) { "20 hours" }

      it "backfills the working_patterns_details field with the full time working patterns details" do
        expect { task.invoke }.to change { vacancy.reload.working_patterns_details }.from(nil).to("20 hours")
      end
    end
  end

  context "with a vacancy created pre-migration date" do
    let(:created_at) { migration_date - 1.day }

    context "with full_time_details and part_time_details" do
      let(:working_patterns) { %w[full_time part_time] }
      let(:full_time_details) { "36 hours" }
      let(:part_time_details) { "20 hours" }

      include_examples "does not backfill working_patterns_details field"
    end

    context "without full_time_details and part_time_details" do
      let(:working_patterns) { [] }
      let(:full_time_details) { "" }
      let(:part_time_details) { "" }

      include_examples "does not backfill working_patterns_details field"
    end

    context "with only full_time_details" do
      let(:working_patterns) { %w[full_time] }
      let(:full_time_details) { "36 hours" }
      let(:part_time_details) { "" }

      include_examples "does not backfill working_patterns_details field"
    end

    context "with only part_time_details" do
      let(:working_patterns) { %w[part_time] }
      let(:full_time_details) { "" }
      let(:part_time_details) { "20 hours" }

      include_examples "does not backfill working_patterns_details field"
    end
  end
end
