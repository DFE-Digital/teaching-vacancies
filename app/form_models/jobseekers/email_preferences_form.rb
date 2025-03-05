class Jobseekers::EmailPreferencesForm
  include ActiveModel::Model
  
  attr_accessor :email_opt_out, :email_opt_out_reason, :email_opt_out_comment
  
  validates :email_opt_out_reason, presence: true, if: -> { email_opt_out == "true" }
  validates :email_opt_out_comment, presence: true, if: -> { email_opt_out == "true" && email_opt_out_reason == "other_reason" }
  
  def initialize(jobseeker, params = {})
    @email_opt_out = params[:email_opt_out] || jobseeker.email_opt_out.to_s
    @email_opt_out_reason = params[:email_opt_out_reason] || jobseeker.email_opt_out_reason
    @email_opt_out_comment = params[:email_opt_out_comment] || jobseeker.email_opt_out_comment
  end
end