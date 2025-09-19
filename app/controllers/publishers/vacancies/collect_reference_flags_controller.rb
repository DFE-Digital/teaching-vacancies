# frozen_string_literal: true

module Publishers
  module Vacancies
    # This is the flow where the user has not selected TV for reference collection,
    # but later changes their mind and is put back into a mini-flow where the
    # reference questions are asked again
    class CollectReferenceFlagsController < ReferencesAndSelfDisclosureBaseController
      before_action :set_job_application

      steps(:collect_references, :ask_references_email)

      def show
        if step != Wicked::FINISH_STEP
          @form = form_class.new
        end
        render_wizard
      end

      def update
        @form = form_for_update
        if @form.valid?
          case step
          when :collect_references
            if @form.collect_references
              redirect_to next_wizard_path collect_references: @form.collect_references
            else
              redirect_to finish_wizard_path
            end
          else
            complete_process
            redirect_to next_wizard_path
          end
        else
          render step
        end
      end

      private

      def complete_process
        ReferenceRequest.transaction do
          ReferenceRequest.create_for_external!(@job_application)
          Publishers::CollectReferencesMailer.inform_applicant_about_references(@job_application).deliver_later if @form.contact_applicants
        end
      end

      def set_job_application
        @job_application = vacancy.job_applications.find params[:job_application_id]
        # This has to be set as it is used in the ask_references_email partial
        @job_applications = [@job_application]
      end

      def finish_wizard_path
        pre_interview_checks_organisation_job_job_application_path(vacancy.id, @job_application)
      end
    end
  end
end
