require "rails_helper"

RSpec.describe StreamEqualOpportunitiesReportPublicationJob do
  subject(:job) { described_class.perform_later }

  let(:vacancy) do
    instance_double(Vacancy,
                    publish_equal_opportunities_report?: publish_report?,
                    equal_opportunities_report: report)
  end
  let(:publish_report?) { true }
  let(:report) { instance_double(EqualOpportunitiesReport, trigger_event: nil) }

  before do
    allow(Vacancy).to receive_message_chain(:expired_yesterday, :listed).and_return([vacancy])
  end

  context "when the vacancy has had no applications" do
    let(:report) { nil }

    it "doesn't throw an error" do
      expect { perform_enqueued_jobs { job } }.not_to raise_exception
    end
  end

  it "triggers an equal opportunities report event for vacancies that expired yesterday" do
    perform_enqueued_jobs { job }
    expect(report).to have_received(:trigger_event)
  end

  context "when the vacancy does not have enough applicants to publish the equal opportunities report" do
    let(:publish_report?) { false }

    it "does not trigger an event for that report" do
      perform_enqueued_jobs { job }
      expect(report).not_to have_received(:trigger_event)
    end
  end
end
