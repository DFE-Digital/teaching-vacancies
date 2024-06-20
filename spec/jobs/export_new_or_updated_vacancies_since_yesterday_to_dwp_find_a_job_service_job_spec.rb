require "rails_helper"

RSpec.describe ExportNewOrUpdatedVacanciesSinceYesterdayToDwpFindAJobServiceJob do
  subject(:job) { described_class.perform_later }

  let(:upload) { instance_double(Vacancies::Export::DwpFindAJob::NewAndEdited::Upload, call: nil) }

  before do
    allow(Vacancies::Export::DwpFindAJob::NewAndEdited::Upload).to receive(:new).and_return(upload)
  end

  context "when DisableExpensiveJobs is enabled" do
    before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(true) }

    it "does not call the upload service" do
      perform_enqueued_jobs { job }
      expect(Vacancies::Export::DwpFindAJob::NewAndEdited::Upload).not_to have_received(:new)
    end
  end

  context "when DisableExpensiveJobs is not enabled" do
    before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false) }

    it "calls the upload service passing the time 25 hours before now" do
      freeze_time do
        perform_enqueued_jobs { job }
        expect(Vacancies::Export::DwpFindAJob::NewAndEdited::Upload).to have_received(:new).with(25.hours.ago)
        expect(upload).to have_received(:call)
      end
    end
  end
end
