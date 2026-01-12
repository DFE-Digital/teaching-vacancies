# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class ReligiousReferencesController < BaseController
        before_action :set_job_application

        def edit
          @note = Note.new
        end

        def update
          @job_application.religious_reference_request.update!(religious_reference_params)
          redirect_to pre_interview_checks_organisation_job_job_application_path(@vacancy.id, @job_application.id)
        end

        private

        def religious_reference_params
          params.expect(job_application: [:status])
        end
      end
    end
  end
end
