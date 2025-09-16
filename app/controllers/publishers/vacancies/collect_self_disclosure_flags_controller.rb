# frozen_string_literal: true

module Publishers
  module Vacancies
    # This is the flow where the user has not selected TV for self disclosure,
    # but later changes their mind and is put back into a mini-flow
    class CollectSelfDisclosureFlagsController < ReferencesAndSelfDisclosureBaseController
      before_action :set_job_application

      steps(:collect_self_disclosure)

      def show
        if step != Wicked::FINISH_STEP
          @form = form_class.new
        end
        render_wizard
      end

      def update
        @form = form_for_update
        if @form.valid?
          if @form.collect_self_disclosure
            SelfDisclosureRequest.create_and_notify!(@job_application)
          end
          redirect_to next_wizard_path
        else
          render step
        end
      end

      private

      def set_job_application
        @job_application = vacancy.job_applications.find params[:job_application_id]
      end

      def finish_wizard_path
        pre_interview_checks_organisation_job_job_application_path(vacancy.id, @job_application)
      end
    end
  end
end
