require "rails_helper"

RSpec.describe MigratePersonalStatementBatchJob do
  describe "#perform" do
    let(:job_application_with_statement) do
      create(:job_application, personal_statement: "This is my personal statement").tap do |ja|
        ja.content.destroy!
      end
    end
    let(:job_application_with_content) do
      create(:job_application, personal_statement: "Some statement").tap do |ja|
        ja.update!(content: "Already has content")
      end
    end
    let(:job_application_no_statement) { create(:job_application, personal_statement: "") }

    let(:job_application_ids) do
      [
        job_application_with_statement.id,
        job_application_with_content.id,
        job_application_no_statement.id,
      ]
    end

    it "migrates personal_statement to content for applications with personal statement" do
      expect { described_class.new.perform(job_application_ids) }
        .to change { job_application_with_statement.reload.content.to_plain_text.strip }
        .from("")
        .to("This is my personal statement")
    end

    it "overwrites existing content for applications that already have content" do
      expect { described_class.new.perform(job_application_ids) }
        .to change { job_application_with_content.reload.content.to_plain_text.strip }
        .from("Already has content")
        .to("Some statement")
    end

    it "processes applications with no personal statement without error" do
      expect { described_class.new.perform(job_application_ids) }.not_to(change { job_application_no_statement.reload.content.to_plain_text.strip })
    end

    it "handles errors gracefully and logs them" do
      job_app = create(:job_application, personal_statement: "Test statement")
      # rubocop:disable RSpec/MessageChain
      allow(JobApplication).to receive_message_chain(:where, :find_each).and_yield(job_app)
      # rubocop:enable RSpec/MessageChain
      allow(job_app).to receive(:content).and_return(ActionText::RichText.new)
      allow(job_app.content).to receive(:present?).and_return(false)
      allow(job_app).to receive(:update!).and_raise(StandardError, "Database error")
      allow(Rails.logger).to receive(:error)

      expect { described_class.new.perform([job_app.id]) }.not_to raise_error
      expect(Rails.logger).to have_received(:error).with(/Error migrating JobApplication #{job_app.id}: Database error/)
    end
  end
end
