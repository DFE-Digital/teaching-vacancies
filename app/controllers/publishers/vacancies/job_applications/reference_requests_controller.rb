# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class ReferenceRequestsController < Publishers::Vacancies::JobApplications::BaseController
        before_action :set_job_application, :set_reference_request

        def show; end

        def mark_as_received
          @form = Publishers::JobApplication::MarkAsReceivedForm.new
        end

        def update
          mark_params = params.fetch("publishers_job_application_mark_as_received_form", {}).permit(:reference_satisfactory)
          @form = Publishers::JobApplication::MarkAsReceivedForm.new(mark_params)
          if @form.valid?
            @reference_request.update!(marked_as_complete: true) if @form.reference_satisfactory
            redirect_to organisation_job_job_application_reference_request_path(vacancy.id, @job_application.id, @reference_request.id)
          else
            render "mark_as_received"
          end
        end

        private

        def set_reference_request
          @reference_request = ReferenceRequest.where(referee: @job_application.referees).find params[:id]
        end
      end
    end
  end
end
