require "rails_helper"
require "teaching_vacancies_api"

RSpec.describe "rake data:seed_from_api:vacancies", type: :task do
  let(:teaching_vacancies_api) { instance_double(TeachingVacancies::API) }
  let(:feature_enabled?) { true }
  let(:current_database) { "tvs_development" }
  before do
    allow(TeachingVacancies::API).to receive(:new).and_return(teaching_vacancies_api)
    allow(ImportVacanciesFeature).to receive(:enabled?).and_return(feature_enabled?)
    allow(Vacancy.connection).to receive(:current_database).and_return(current_database)
  end

  it "queues jobs to add vacancies from the Teaching Vacancies API" do
    vacancies = [double]
    allow(teaching_vacancies_api).to receive(:jobs).and_return(vacancies)

    vacancies.each do |vacancy|
      expect(SaveJobPostingToVacancyJob).to receive(:perform_later).with(vacancy)
    end

    task.execute
  end

  context "when in production" do
    before { allow(Rails.env).to receive(:production?).and_return(true) }

    it "returns early and doesn’t call the API at all" do
      expect(teaching_vacancies_api).not_to receive(:jobs)
      expect(SaveJobPostingToVacancyJob).not_to receive(:perform_later)

      task.execute
    end
  end

  context "when the import vacancies feature is NOT enabled" do
    let(:feature_enabled?) { false }

    it "returns early and doesn’t call the API at all" do
      expect(teaching_vacancies_api).not_to receive(:jobs)
      expect(SaveJobPostingToVacancyJob).not_to receive(:perform_later)

      task.execute
    end
  end

  context "when the database name is NOT in the whitelist" do
    let(:current_database) { "tvs2_production" }

    it "returns early and doesn’t call the API at all" do
      expect(teaching_vacancies_api).not_to receive(:jobs)
      expect(SaveJobPostingToVacancyJob).not_to receive(:perform_later)

      task.execute
    end
  end

  context "when there is a response error" do
    before do
      allow(teaching_vacancies_api).to receive(:jobs).and_raise(HTTParty::ResponseError, "foo")
    end

    it "logs the error" do
      expect(Rails.logger).to receive(:warn).with("Teaching Vacancies API response error: foo")
      task.execute
    end
  end
end
