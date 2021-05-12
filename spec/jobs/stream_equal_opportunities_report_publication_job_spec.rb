require "rails_helper"

RSpec.describe StreamEqualOpportunitiesReportPublicationJob do
  subject(:job) { described_class.perform_later }
  let(:vacancy) { create(:vacancy) }
  let(:publish_report?) { true }
  let(:event_data) { {} }

  before do
    vacancy.create_equal_opportunities_report
    allow(Vacancy).to receive_message_chain(:expired_yesterday, :listed).and_return([vacancy])
    allow(vacancy).to receive(:publish_equal_opportunities_report?).and_return(publish_report?)
    allow_any_instance_of(EqualOpportunitiesReport).to receive(:event_data).and_return(event_data)
  end

  context "when the vacancy has had no applications" do
    it "doesn't throw an error" do
      expect { perform_enqueued_jobs { job } }.not_to raise_exception
    end
  end

  it "triggers an equal opportunities report event for vacancies that expired yesterday" do
    expect_any_instance_of(Event).to receive(:trigger).with(:equal_opportunities_report_published, event_data)

    perform_enqueued_jobs { job }
  end

  context "when the vacancy does not have enough applicants to publish the equal opportunities report" do
    let(:publish_report?) { false }

    it "does not trigger an event for that report" do
      expect(Event).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
