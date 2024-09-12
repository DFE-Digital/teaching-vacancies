class Jobseekers::AccountTransfersController < Jobseekers::BaseController
  def new
    @account_transfer_form = Jobseekers::AccountTransferForm.new
    @email = params["email"]
  end

  def create
    @account_transfer_form = Jobseekers::AccountTransferForm.new(request_account_transfer_email_form_params)

    if @account_transfer_form.valid?
      if transfer_account_data
        flash[:success] = "Your account details have been transferred successfully!"
        redirect_to jobseekers_profile_path
      end
    else
      render :new
    end
  end

  private

  def request_account_transfer_email_form_params
    params.require(:jobseekers_account_transfer_form).permit(:account_merge_confirmation_code, :email)
  end

  def transfer_account_data
    account_to_transfer = Jobseeker.find_by(email: @account_transfer_form.email)

    profile = account_to_transfer.jobseeker_profile
    if profile
      current_jobseeker.jobseeker_profile.destroy! if current_jobseeker.jobseeker_profile
      profile.jobseeker_id = current_jobseeker.id
      profile.save!
    end

    feedbacks = account_to_transfer.feedbacks
    feedbacks.each do |feedback|
      feedback.jobseeker_id = current_jobseeker.id
      feedback.save!
    end

    job_applications = account_to_transfer.job_applications
    job_applications.each do |job_application|
      job_application.jobseeker_id = current_jobseeker.id
      job_application.save!
    end
    
    saved_jobs = account_to_transfer.saved_jobs
    saved_jobs.each do |saved_job|
      saved_job.jobseeker_id = current_jobseeker.id
      saved_job.save!
    end

    Subscription.where(email: account_to_transfer.email).each {|subscription| subscription.update(email: current_jobseeker.email)}
  end
end


# has_many :feedbacks, dependent: :destroy, inverse_of: :jobseeker
# has_many :job_applications, dependent: :destroy
# has_many :saved_jobs, dependent: :destroy
# has_one :jobseeker_profile