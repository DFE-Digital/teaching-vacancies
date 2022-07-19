class Jobseekers::BaseController < ApplicationController
  include ReturnPathTracking
  include Authenticated

  self.authentication_scope = :jobseeker

  helper_method :show_job_applications?, :show_saved_jobs?, :show_subscriptions?

  def show_job_applications?
    current_jobseeker.job_applications.any?
  end

  def show_saved_jobs?
    current_jobseeker.saved_jobs.any?
  end

  def show_subscriptions?
    Subscription.active.where(email: current_jobseeker.email).any?
  end
end
