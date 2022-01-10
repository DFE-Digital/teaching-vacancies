require "rails_helper"
RSpec.describe VacanciesPresenter do
  let(:vacancies_presenter) { VacanciesPresenter.new(vacancies) }

  describe "#each" do
    it "is delegated to the decorated collection" do
      build_stubbed_list(:vacancy, 3)
      vacancies = Vacancy.all.page(1)
      decorated_vacancies = vacancies.map { |v| VacancyPresenter.new(v) }
      vacancies_presenter = VacanciesPresenter.new(vacancies)

      allow(vacancies_presenter).to receive(:decorated_collection).and_return(decorated_vacancies)
      expect(decorated_vacancies).to receive(:each)

      vacancies_presenter.each
    end
  end

  describe "#previous_api_url" do
    let(:vacancies) { double(:vacancies, map: [], prev_page:, total_count: 0) }

    context "when there is a previous page" do
      let(:prev_page) { 4 }

      it "returns the full url of the next page" do
        expect(vacancies_presenter.previous_api_url).to eq("http://localhost:3000/api/v1/jobs.json?page=4")
      end
    end

    context "when there is no previous page" do
      let(:prev_page) { nil }

      it "returns nil" do
        expect(vacancies_presenter.previous_api_url).to be_nil
      end
    end
  end

  describe "#next_api_url" do
    let(:vacancies) { double(:vacancies, map: [], next_page:, total_count: 0) }

    context "when there is a next page" do
      let(:next_page) { 2 }

      it "returns the full url of the next page" do
        expect(vacancies_presenter.next_api_url).to eq("http://localhost:3000/api/v1/jobs.json?page=2")
      end
    end

    context "when there is no next page" do
      let(:next_page) { nil }

      it "returns nil" do
        expect(vacancies_presenter.next_api_url).to be_nil
      end
    end
  end
end
