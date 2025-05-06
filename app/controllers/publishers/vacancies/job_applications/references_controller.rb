# frozen_string_literal: true

module Publishers
  module Vacancies
    module JobApplications
      class ReferencesController < Publishers::Vacancies::JobApplications::BaseController
        def show
          @reference = JobReference.where(referee: job_application.referees).find params[:id]
        end
      end
    end
  end
end
