# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class ReferenceRequestsController < Publishers::Vacancies::JobApplications::BaseController
        before_action :set_job_application, :set_reference_request

        def show
          @referee = @reference_request.referee
          @notes_form = Publishers::JobApplication::NotesForm.new
        end

        # changing the email address of the referee
        def edit
          @form = email_form_class.new
        end

        def update
          update_params = params.fetch(param_key(email_form_class), {}).permit(*email_form_class.fields)
          @form = email_form_class.new(update_params)
          if @form.valid?
            @reference_request.change_referee_email!(@form.email)
            flash[:success] = t(".change_email_success")
            redirect_to organisation_job_job_application_reference_request_path(vacancy.id, @job_application.id, @reference_request.id)
          else
            render :edit
          end
        end

        def reference_received
          @form = reference_received_class.new
        end

        def mark_as_received
          mark_params = params.fetch(param_key(reference_received_class), {}).permit(:reference_satisfactory)
          @form = reference_received_class.new(mark_params)
          if @form.valid?
            @reference_request.update!(marked_as_complete: true) if @form.reference_satisfactory
            redirect_to organisation_job_job_application_reference_request_path(vacancy.id, @job_application.id, @reference_request.id)
          else
            render :reference_received
          end
        end

        private

        def email_form_class
          ChangeEmailAddressForm
        end

        def reference_received_class
          MarkReferenceAsReceivedForm
        end

        def param_key(form_class)
          ActiveModel::Naming.param_key(form_class)
        end

        def set_reference_request
          @reference_request = ReferenceRequest.where(referee: @job_application.referees).find params[:id]
        end
      end
    end
  end
end
