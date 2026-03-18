# frozen_string_literal: true

module Publishers
  class BuildVacancyTemplatesController < Publishers::BaseController
    include Wicked::Wizard
    include Publishers::Wizardable

    before_action :load_template

    steps(*VacancyTemplates::VacancyTemplateStepProcess.steps)

    def show
      if step != Wicked::FINISH_STEP
        if VacancyTemplates::VacancyTemplateStepProcess.skip_step? step, @template
          skip_step
        else
          @form = form_class.load_from_model(@template, current_publisher: current_publisher)
        end
      end

      render_wizard
    end

    def update
      @form = form_class.load_from_params(params.fetch(form_key, {}).permit(form_class.fields), @template, current_publisher: current_publisher)

      if @form.valid?
        @template.update!(@form.params_to_save)
        redirect_to_next_step
      else
        render_wizard
      end
    end

    private

    def redirect_to_next_step
      if save_and_finish_later?
        redirect_to organisation_vacancy_templates_path
      elsif back_to_show?
        redirect_to organisation_vacancy_template_path(@template)
      else
        redirect_to next_wizard_path
      end
    end

    def save_and_finish_later?
      params["save_and_finish_later"] == "true"
    end

    def back_to_show?
      params[form_key]["back_to_show"] == "true"
    end

    def form_key
      ActiveModel::Naming.param_key(form_class)
    end

    def finish_wizard_path
      organisation_vacancy_templates_path
    end

    def form_class
      VacancyTemplates::VacancyTemplateStepProcess.form_class(step)
    end

    def load_template
      @template = current_organisation.vacancy_templates.find(params[:vacancy_template_id])
    end
  end
end
