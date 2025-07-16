require "rails_helper"

class FooVacancySource
  def self.source_name
    "foo_source"
  end
end

class BarVacancySource
  def self.source_name
    "bar_source"
  end
end

RSpec.describe ImportFromVacancySourcesJob do
  before do
    stub_const("ImportFromVacancySourcesJob::SOURCES", [FooVacancySource, BarVacancySource])
  end

  describe "#perform" do
    context "when DisableIntegrations is disabled" do
      it "enqueues a job for each source" do
        expect { described_class.perform_now }
          .to have_enqueued_job(ImportFromVacancySourceJob).exactly(2).times
          .and have_enqueued_job(ImportFromVacancySourceJob).with(FooVacancySource).on_queue(:low).once
          .and have_enqueued_job(ImportFromVacancySourceJob).with(BarVacancySource).on_queue(:low).once
      end
    end

    context "when DisableIntegrations is enabled", :disable_integrations do
      it "does not enqueue any jobs" do
        expect { described_class.perform_now }.not_to have_enqueued_job(ImportFromVacancySourceJob)
      end
    end
  end
end
