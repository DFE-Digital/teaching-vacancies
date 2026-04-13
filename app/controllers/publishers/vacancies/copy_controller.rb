module Publishers
  module Vacancies
    class CopyController < BaseController
      before_action :set_vacancy

      def new
        @form = current_organisation.vacancy_templates.build
      end

      def create
        @form = current_organisation.vacancy_templates.create(
          vacancy.attributes
                 .except(*(VacancyTemplate::IGNORED_ATTRIBUTES + %w[job_roles key_stages phases working_patterns]))
                 .merge(copy_vacancy_params)
                 .merge(job_roles: vacancy.job_roles,
                        phases: vacancy.phases,
                        working_patterns: vacancy.working_patterns,
                        key_stages: vacancy.key_stages),
        )
        if @form.valid?
          redirect_to organisation_vacancy_templates_path, success: t("publishers.vacancies.show.copied.success")
        else
          render "new"
        end
      end

      private

      def copy_vacancy_params
        params.expect(vacancy_template: [:name])
      end
    end
  end
end
