require "rails_helper"

class FakeVacancySource
  cattr_writer :vacancies

  def self.source_name
    "fake_source"
  end

  def each(...)
    @@vacancies.each(...)
  end
end

RSpec.describe ImportFromVacancySourcesJob do
  before do
    stub_const("ImportFromVacancySourcesJob::SOURCES", [FakeVacancySource])
    FakeVacancySource.vacancies = vacancies_from_source
    expect(DisableExpensiveJobs).to receive(:enabled?).and_return(false)
  end

  let(:school) { create(:school) }

  describe "#perform" do
    context "when a new valid vacancy comes through" do
      let(:vacancies_from_source) { [vacancy] }
      let(:vacancy) { build(:vacancy, :published, :external, phases: %w[secondary], organisations: [school]) }

      it "saves the vacancy" do
        expect { described_class.perform_now }.to change { Vacancy.count }.by(1)
      end
    end

    context "when a new vacancy comes through but isn't valid" do
      let(:vacancies_from_source) { [vacancy] }
      let(:vacancy) { build(:vacancy, :published, :external, phases: [], organisations: [school], job_title: "") }

      it "does not save the vacancy to the Vacancies table" do
        expect { described_class.perform_now }.to change { Vacancy.count }.by(0)
      end

      it "saves the vacancy in the FailedVacancyImports table" do
        expect { described_class.perform_now }.to change { FailedImportedVacancy.count }.by(1)
      end

      it "saves the vacancy in the FailedVacancyImports with the import errors and identifiable info" do
        described_class.perform_now

        expect(FailedImportedVacancy.first.source).to eq("fake_source")
        expect(FailedImportedVacancy.first.external_reference).to eq("J3D1")
        expect(FailedImportedVacancy.first.import_errors.first).to eq("job_title:[can't be blank]")
        expect(FailedImportedVacancy.first.import_errors.last).to eq("phases:[can't be blank]")
      end
    end

    context "when a live vacancy no longer comes through" do
      let!(:vacancy) { create(:vacancy, :published, :external, phases: %w[secondary], organisations: [school], external_source: "fake_source", external_reference: "123", updated_at: 1.hour.ago) }
      let(:vacancies_from_source) { [] }

      it "sets the vacancy to have the correct status" do
        expect { described_class.perform_now }
          .to change { vacancy.reload.status }
          .from("published").to("removed_from_external_system")
      end
    end

    context "when an expired vacancy no longer comes through" do
      let!(:vacancy) { create(:vacancy, :expired_yesterday, :external, phases: %w[secondary], organisations: [school], external_source: "fake_source", external_reference: "123", updated_at: 1.hour.ago) }
      let(:vacancies_from_source) { [] }

      it "does not change the vacancy's status" do
        expect { described_class.perform_now }.not_to(change { vacancy.reload.status })
      end
    end
  end
end
