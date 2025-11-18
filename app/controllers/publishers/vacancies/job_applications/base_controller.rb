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

        def notes_form_params
          params[:note].permit(:content).merge(publisher: current_publisher)
        end

        def create_note_from_params(success_url, failure_template)
          @note = @job_application.notes.create(notes_form_params)

          if @note.persisted?
            redirect_to success_url,
                        success: t("publishers.vacancies.job_applications.notes.create.success")
          else
            render failure_template
          end
        end
      end
    end
  end
end
