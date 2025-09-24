# frozen_string_literal: true

module Publishers
  class CurrentYearStatisticsController < StatisticsController
    before_action :set_bar_chart

    def index
      presenter = VacancyStatisticsPresenter.new(vacancies)
      @referrer_counts = presenter.referrer_counts
      @vacancy_counts = vacancies.count
    end

    def equal_opportunities
      data = VacancyStatisticsPresenter.new(vacancies)
      equal_opportunities = data.equal_opportunities_data
      @age_counts = equal_opportunities.fetch(:age)
      @disability_counts = equal_opportunities.fetch(:disability)
      @ethnicity_counts = equal_opportunities.fetch(:ethnicity)
      @gender_counts = equal_opportunities.fetch(:gender)
      @orientation_counts = equal_opportunities.fetch(:orientation)
      @religion_counts = equal_opportunities.fetch(:religion)
    end

    private

    def vacancies
      super.active_in_current_academic_year
    end

    def set_bar_chart
      @bar_chart = params[:view] != "table"
    end
  end
end
