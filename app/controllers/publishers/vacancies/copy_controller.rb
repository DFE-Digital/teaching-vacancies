module Publishers
  module Vacancies
    class CopyController < BaseController
      before_action :set_vacancy

      def new
        @form = current_organisation.vacancy_templates.build
      end

      def create
        @form = create_template vacancy
        if @form.valid?
          redirect_to organisation_vacancy_templates_path, success: t("publishers.vacancies.show.copied.success")
        else
          render "new"
        end
      end

      private

      # rubocop can't seem to see that the caller check the return from this method
      # rubocop:disable Rails/SaveBang
      def create_template(vacancy)
        receive_applications = if VacancyTemplate.receive_applications.key?(vacancy.receive_applications)
                                 vacancy.receive_applications
                               end

        current_organisation.vacancy_templates.create(
          vacancy.attributes
                 .except(*(VacancyTemplate::IGNORED_ATTRIBUTES + %w[job_roles key_stages phases working_patterns receive_applications]))
                 .merge(copy_vacancy_params)
                 .merge(job_roles: vacancy.job_roles,
                        phases: vacancy.phases,
                        working_patterns: vacancy.working_patterns,
                        key_stages: vacancy.key_stages,
                        receive_applications: receive_applications),
        )
      end
      # rubocop:enable Rails/SaveBang

      def copy_vacancy_params
        params.expect(vacancy_template: [:name])
      end
    end
  end
end
