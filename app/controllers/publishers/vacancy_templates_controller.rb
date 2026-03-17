# frozen_string_literal: true

module Publishers
  class VacancyTemplatesController < Publishers::BaseController
    before_action :load_template, only: %i[show]

    def index
      @vacancy_types = %i[live draft pending expired awaiting_feedback]

      # TODO: scope by publisher/organisation
      @templates = VacancyTemplate.all
      @count = @templates.count
    end

    def show; end

    def new
      @template = VacancyTemplate.new
    end

    def create
      template = VacancyTemplate.create! template_params
      redirect_to organisation_vacancy_template_build_path(template, Wicked::FIRST_STEP)
    end

    private

    def template_params
      params.expect(vacancy_template: [:name])
    end

    def load_template
      @template = VacancyTemplate.find(params[:id])
    end
  end
end
