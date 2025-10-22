# frozen_string_literal: true

module Jobseekers
  class FormPreviewsController < Jobseekers::JobApplications::BaseController
    def show
      document = ::DocumentPreviewService.call(params[:id], job_application.vacancy)
      send_data(document.data, filename: document.filename, disposition: "inline")
    end
  end
end
