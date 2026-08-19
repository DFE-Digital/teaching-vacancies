# frozen_string_literal: true

class JobApplicationsController < ApplicationController
  include JobApplicationsPdfHelper

  # simplecov:disable
  def show
    job_application = JobApplication.includes(:employments, :referees, :training_and_cpds).find(params[:id])
    document = submitted_application_form(job_application)
    send_data(document.data, filename: document.filename, disposition: "inline")
  end
  # simplecov:enable
end
