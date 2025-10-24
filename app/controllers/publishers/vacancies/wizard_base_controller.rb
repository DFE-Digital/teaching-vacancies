require "google_indexing"

module Publishers
  module Vacancies
    class WizardBaseController < BaseController
      include Publishers::Wizardable

      delegate :all_steps_valid?, :next_invalid_step, to: :form_sequence

      private

      helper_method :current_step, :step_process, :all_steps_valid?, :next_invalid_step, :back_path

      def step_process
        Publishers::Vacancies::VacancyStepProcess.new(
          current_step || :review,
          vacancy: vacancy,
          organisation: current_organisation,
        )
      end

      def form_sequence
        @form_sequence ||= Publishers::VacancyFormSequence.new(
          vacancy: vacancy,
          organisation: current_organisation,
          step_process: step_process,
        )
      end

      def redirect_to_next_step
        if save_and_finish_later?
          redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success") and return
        end
        
        if step.name == "contact_details" && !vacancy.contact_email_belongs_to_a_publisher?
          # we don't validate confirm_contact_details step in all_steps_valid? which means all_steps_valid is true at this point, so we need to manually redirect here
          # to ensure the user sees the confirm contact_details page  
          redirect_to organisation_job_build_path(vacancy.id, :confirm_contact_details) and return
        end

        if all_steps_valid?
          if vacancy.published?
            redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success")
          else
            redirect_to organisation_job_review_path(vacancy.id)
          end
        else
          redirect_to organisation_job_build_path(vacancy.id, next_invalid_step)
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
