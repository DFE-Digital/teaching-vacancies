require "google_indexing"

module Publishers
  module Vacancies
    class WizardBaseController < BaseController
      include Publishers::Wizardable

      private

      helper_method :current_step, :step_process, :back_path

      def step_process
        Publishers::Vacancies::VacancyStepProcess.new(
          current_step || :review,
          vacancy: vacancy,
          organisation: current_organisation,
        )
      end

      def redirect_to_next_step
        if save_and_finish_later?
          redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success")
        elsif step_process.all_steps_valid?
          if vacancy.published?
            redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success")
          else
            redirect_to organisation_job_review_path(vacancy.id)
          end
        else
          redirect_to organisation_job_build_path(vacancy.id, step_process.next_invalid_step)
        end
      end

      def back_path
        if params[:back_to_show] == "true"
          organisation_job_path(vacancy.id)
        elsif step_process.previous_step
          organisation_job_build_path(vacancy.id, step_process.previous_step)
        else
          organisation_jobs_with_type_path(:live)
        end
      end

      def save_and_finish_later?
        params["save_and_finish_later"] == "true"
      end
    end
  end
end
