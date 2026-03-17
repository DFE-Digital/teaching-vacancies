module Publishers
  module Vacancies
    class CopyController < BaseController
      include Publishers::VacancyCopy

      before_action :set_vacancy

      def new
        @form = CopyVacancyForm.new
      end

      def create
        @form = CopyVacancyForm.new(copy_vacancy_params)
        if @form.valid?
          VacancyTemplate.create!(
            vacancy.attributes
                   .except(*(VacancyTemplate::IGNORED_ATTRIBUTES + %w[job_roles key_stages phases working_patterns]))
                   .merge(name: @form.name, job_roles: vacancy.job_roles,
                          phases: vacancy.phases,
                          working_patterns: vacancy.working_patterns,
                          key_stages: vacancy.key_stages),
          )

          # copy_vacancy(vacancy, @form.name)

          # redirect_to organisation_job_path(new_vacancy.id), success: t("publishers.vacancies.show.copied.success")
          redirect_to organisation_vacancy_templates_path, success: t("publishers.vacancies.show.copied.success")
        else
          render "new"
        end
      end

      private

      def copy_vacancy_params
        params.expect(publishers_vacancies_copy_vacancy_form: [:name])
      end
    end
  end
end
