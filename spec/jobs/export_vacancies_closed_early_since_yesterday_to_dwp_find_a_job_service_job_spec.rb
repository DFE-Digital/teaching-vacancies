require "rails_helper"

RSpec.describe ExportVacanciesClosedEarlySinceYesterdayToDwpFindAJobServiceJob do
  subject(:job) { described_class.perform_later }

  let(:service) { instance_double(Vacancies::Export::DwpFindAJob::ClosedEarly, call: nil) }

  before do
    allow(Vacancies::Export::DwpFindAJob::ClosedEarly).to receive(:new).and_return(service)
  end

  context "when DisableIntegrations is enabled", :disable_integrations do
    it "does not call the service" do
      perform_enqueued_jobs { job }
      expect(Vacancies::Export::DwpFindAJob::ClosedEarly).not_to have_received(:new)
    end
  end

  context "when DisableIntegrations is not enabled" do
    it "calls the service passing the time 25 hours before now" do
      freeze_time do
        perform_enqueued_jobs { job }
        expect(Vacancies::Export::DwpFindAJob::ClosedEarly).to have_received(:new).with(25.hours.ago)
        expect(service).to have_received(:call)
      end
    end
  end
end
