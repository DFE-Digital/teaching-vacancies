# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class ReferenceRequestsController < BaseController
        before_action :set_job_application, :set_reference_request

        def show
          @referee = RefereePresenter.new(@reference_request.referee)
          @job_reference = @reference_request.job_reference
          @notes_form = Publishers::JobApplication::NotesForm.new
          respond_to do |format|
            format.html
            format.pdf { send_reference_pdf }
          end
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
            redirect_to organisation_job_job_application_reference_request_path(@vacancy.id, @job_application.id, @reference_request.id)
          else
            render :edit
          end
        end

        def mark_as_received
          # don't use 'received' state as it confuses us into thinking that this is a job reference waiting to be looked at
          @reference_request.received_off_service!
          redirect_to organisation_job_job_application_reference_request_path(@vacancy.id, @job_application.id, @reference_request.id)
        end

        def send_reminder_email
          @reference_request.resend_email
          redirect_to organisation_job_job_application_reference_request_path(@vacancy.id, @job_application.id, @reference_request.id)
        end

        def mark_as_complete
          @reference_request.update!(marked_as_complete: true)
          redirect_to organisation_job_job_application_reference_request_path(@vacancy.id, @job_application.id, @reference_request.id)
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

        def send_reference_pdf
          pdf = ReferencePdfGenerator.new(@referee).generate

          send_data(
            pdf.render,
            filename: "reference_#{@referee.id}.pdf",
            type: "application/pdf",
            disposition: "inline",
          )
        end
      end
    end
  end
end
