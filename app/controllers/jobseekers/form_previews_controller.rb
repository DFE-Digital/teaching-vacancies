# frozen_string_literal: true

module Jobseekers
  class FormPreviewsController < Jobseekers::JobApplications::BaseController
    layout "print"

    def show
      @vacancy = job_application.vacancy
    end
  end
end
