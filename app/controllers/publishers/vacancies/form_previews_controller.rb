# frozen_string_literal: true

module Publishers
  module Vacancies
    class FormPreviewsController < Publishers::Vacancies::BaseController
      PREVIEWS = {
        plain: ->(vacancy) { helpers.job_application_sample(vacancy) },
        religious: ->(vacancy) { helpers.religious_job_application_sample(vacancy) },
        catholic: ->(vacancy) { helpers.catholic_job_application_sample(vacancy) },
      }.freeze

      def show
        job_application = PREVIEWS.fetch(params[:id].to_sym).call(vacancy)

        pdf = JobApplicationPdfGenerator.new(job_application).generate

        send_data(
          pdf.render,
          filename: "job_application_#{job_application.object_id}.pdf",
          type: "application/pdf",
          disposition: "inline",
        )
      end
    end
  end
end
