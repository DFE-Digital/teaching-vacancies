# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class ReligiousReferencesController < BaseController
        before_action :set_job_application

        def edit
          @notes_form = Publishers::JobApplication::NotesForm.new
        end

        def update
          @job_application.update!(religious_reference_received: true)
          redirect_to pre_interview_checks_organisation_job_job_application_path(@vacancy.id, @job_application.id)
        end
      end
    end
  end
end
