# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class OnlineChecksController < BaseController
        before_action :set_job_application

        def edit
          @notes_form = Publishers::JobApplication::NotesForm.new
        end

        def update
          @job_application.update!(online_checks_params)
          flash[:success] = t(".success")
          redirect_to pre_interview_checks_organisation_job_job_application_path(@vacancy.id, @job_application.id)
        end

        private

        def online_checks_params
          params.expect(job_application: [:online_checks])
        end
      end
    end
  end
end
