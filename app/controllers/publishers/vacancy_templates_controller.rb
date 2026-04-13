# frozen_string_literal: true

module Publishers
  class VacancyTemplatesController < Publishers::BaseController
    before_action :load_template, only: %i[show edit update destroy]

    def index
      @vacancy_types = %i[live draft pending expired awaiting_feedback]

      @templates = current_organisation.vacancy_templates
      @count = @templates.count
    end

    def show; end

    def new
      @template = current_organisation.vacancy_templates.build
    end

    def edit; end

    def create
      @template = current_organisation.vacancy_templates.create template_params
      if @template.valid?
        redirect_to organisation_vacancy_template_build_path(@template, Wicked::FIRST_STEP)
      else
        render "new"
      end
    end

    def update
      if @template.update(template_params)
        redirect_to organisation_vacancy_template_path(@template)
      else
        render "edit"
      end
    end

    def destroy
      @template.destroy!
      redirect_to organisation_vacancy_templates_path
    end

    private

    def template_params
      params.expect(vacancy_template: [:name])
    end

    def load_template
      @template = current_organisation.vacancy_templates.find(params[:id])
    end
  end
end
