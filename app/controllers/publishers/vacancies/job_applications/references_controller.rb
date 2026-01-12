# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class ReferencesController < BaseController
        before_action :set_job_application

        def new
          @notes_form = Publishers::JobApplication::NotesForm.new
          @referee = RefereeForm.new
        end

        def create
          @notes_form = Publishers::JobApplication::NotesForm.new
          @referee = RefereeForm.new(referee_form_params)
          if @referee.valid?
            process_referee_details @referee
            redirect_to pre_interview_checks_organisation_job_job_application_path(@vacancy.id, @job_application)
          else
            render "new"
          end
        end

        private

        def referee_form_params
          params.expect(publishers_vacancies_job_applications_referee_form: RefereeForm.fields)
        end

        def process_referee_details(referee_form)
          if referee_form.uploaded_details
            referee = @job_application.referees.create!(name: referee_form.name,
                                                        is_most_recent_employer: false)
            referee.create_reference_request!(reference_form: referee_form.reference_document,
                                              marked_as_complete: true,
                                              status: :received_off_service)
          else
            referee = @job_application.referees.create!(email: referee_form.email,
                                                        job_title: referee_form.job_title,
                                                        name: referee_form.name,
                                                        is_most_recent_employer: false,
                                                        relationship: referee_form.relationship,
                                                        phone_number: referee_form.phone_number,
                                                        organisation: referee_form.organisation)
            ReferenceRequest.create_external_for_referee!(referee)
          end
        end
      end
    end
  end
end
