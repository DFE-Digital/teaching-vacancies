class Jobseekers::AccountTransfer
  def initialize(current_jobseeker, email)
    @current_jobseeker = current_jobseeker
    @account_to_transfer = Jobseeker.find_by(email: email)
  end

  def call
    ActiveRecord::Base.transaction do
      transfer_profile
      transfer_feedbacks
      transfer_job_applications
      transfer_saved_jobs
      update_subscriptions
    end
  end

  private

  def transfer_profile
    profile = @account_to_transfer.jobseeker_profile
    return unless profile

    @current_jobseeker.jobseeker_profile&.destroy!
    profile.update!(jobseeker_id: @current_jobseeker.id)
  end

  def transfer_feedbacks
    @account_to_transfer.feedbacks.each do |feedback|
      feedback.update!(jobseeker_id: @current_jobseeker.id)
    end
  end

  def transfer_job_applications
    @account_to_transfer.job_applications.each do |job_application|
      job_application.update!(jobseeker_id: @current_jobseeker.id)
    end
  end

  def transfer_saved_jobs
    @account_to_transfer.saved_jobs.each do |saved_job|
      saved_job.update!(jobseeker_id: @current_jobseeker.id)
    end
  end

  def update_subscriptions
    Subscription.where(email: @account_to_transfer.email).each do |subscription|
      subscription.update!(email: @current_jobseeker.email)
    end
  end
end
