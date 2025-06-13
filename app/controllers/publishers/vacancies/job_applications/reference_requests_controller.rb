# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class ReferenceRequestsController < Publishers::Vacancies::JobApplications::BaseController
        before_action :set_job_application, :set_reference_request

        def show
          @referee = @reference_request.referee
        end

        def mark_as_received
          @form = form_class.new
        end

        def update
          mark_params = params.fetch(param_key, {}).permit(:reference_satisfactory)
          @form = form_class.new(mark_params)
          if @form.valid?
            @reference_request.update!(marked_as_complete: true) if @form.reference_satisfactory
            redirect_to organisation_job_job_application_reference_request_path(vacancy.id, @job_application.id, @reference_request.id)
          else
            render "mark_as_received"
          end
        end

        private

        def form_class
          Publishers::JobApplication::MarkReferenceAsReceivedForm
        end

        def param_key
          ActiveModel::Naming.param_key(form_class)
        end

        def set_reference_request
          @reference_request = ReferenceRequest.where(referee: @job_application.referees).find params[:id]
        end
      end
    end
  end
end
