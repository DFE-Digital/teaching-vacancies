require "rails_helper"

RSpec.describe ExportVacanciesPublishedAndUpdatedSinceYesterdayToDwpFindAJobServiceJob do
  subject(:job) { described_class.perform_later }

  let(:service) { instance_double(Vacancies::Export::DwpFindAJob::PublishedAndUpdated, call: nil) }

  before do
    allow(Vacancies::Export::DwpFindAJob::PublishedAndUpdated).to receive(:new).and_return(service)
  end

  context "when DisableExpensiveJobs is enabled" do
    before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(true) }

    it "does not call the service" do
      perform_enqueued_jobs { job }
      expect(Vacancies::Export::DwpFindAJob::PublishedAndUpdated).not_to have_received(:new)
    end
  end

  context "when DisableExpensiveJobs is not enabled" do
    before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false) }

    it "calls the service passing the time 25 hours before now" do
      freeze_time do
        perform_enqueued_jobs { job }
        expect(Vacancies::Export::DwpFindAJob::PublishedAndUpdated).to have_received(:new).with(25.hours.ago)
        expect(service).to have_received(:call)
      end
    end
  end
end
