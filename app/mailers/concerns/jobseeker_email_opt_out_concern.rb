module JobseekerEmailOptOutConcern
  extend ActiveSupport::Concern

  # Call this method before sending any non-transactional emails to jobseekers
  # Returns true if the jobseeker has opted out of non-transactional emails
  # Returns false if the jobseeker hasn't opted out or if no jobseeker is provided
  def jobseeker_opted_out?(jobseeker)
    return false if jobseeker.blank?
    
    jobseeker.email_opt_out?
  end
end