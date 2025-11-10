module Publishers
  module Vacancies
    module JobApplications
      class BaseController < Publishers::BaseController
        before_action :set_vacancy

        private

        def set_job_application
          @job_application = @vacancy.job_applications.find(params[:job_application_id] || params[:id]).decorate
        end

        def set_vacancy
          @vacancy = current_organisation.all_listed_vacancies
                                           .find(params[:job_id])
        end
      end
    end
  end
end
