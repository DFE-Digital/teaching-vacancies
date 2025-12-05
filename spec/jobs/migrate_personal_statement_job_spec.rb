require "rails_helper"

RSpec.describe MigratePersonalStatementJob do
  describe "#perform" do
    let!(:job_application_with_statement) do
      create(:job_application, personal_statement: "My personal statement", personal_statement_richtext: nil)
    end

    it "migrates personal_statement to content field" do
      described_class.perform_now([job_application_with_statement.id])

      expect(job_application_with_statement.reload.personal_statement_richtext.to_plain_text).to eq("My personal statement")
    end

    context "when content is already present" do
      let!(:job_application_with_content) do
        create(:job_application, personal_statement: "Old statement", personal_statement_richtext: "Existing content")
      end

      it "skips migration" do
        described_class.perform_now([job_application_with_content.id])

        expect(job_application_with_content.reload.personal_statement_richtext.to_plain_text).to eq("Existing content")
      end
    end

    context "when personal_statement is blank" do
      let!(:job_application_without_statement) do
        create(:job_application, personal_statement: nil, personal_statement_richtext: nil)
      end

      it "skips migration" do
        expect {
          described_class.perform_now([job_application_without_statement.id])
        }.not_to(change { job_application_without_statement.reload.personal_statement_richtext })
      end
    end

    context "when an error occurs during migration" do
      before do
        allow(Rails.logger).to receive(:error)
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(JobApplication).to receive(:save!).and_raise(StandardError.new("Test error"))
        # rubocop:enable RSpec/AnyInstance
      end

      it "logs the error and continues processing" do
        expect {
          described_class.perform_now([job_application_with_statement.id])
        }.not_to raise_error

        expect(Rails.logger).to have_received(:error).with(
          "Error migrating JobApplication #{job_application_with_statement.id}: Test error",
        )
      end
    end

    context "when processing multiple job applications" do
      let!(:job_app_english) { create(:job_application, personal_statement: "Statement about english", personal_statement_richtext: nil) }
      let!(:job_app_maths) { create(:job_application, personal_statement: "Statement to do with maths", personal_statement_richtext: nil) }
      let!(:job_app_french) { create(:job_application, personal_statement: "Ahhh bonjour mon ami", personal_statement_richtext: "Has content") }

      it "migrates only applications without content" do
        described_class.perform_now([job_app_english.id, job_app_maths.id, job_app_french.id])

        expect(job_app_english.reload.personal_statement_richtext.to_plain_text).to eq("Statement about english")
        expect(job_app_maths.reload.personal_statement_richtext.to_plain_text).to eq("Statement to do with maths")
        expect(job_app_french.reload.personal_statement_richtext.to_plain_text).to eq("Has content")
      end
    end
  end
end
