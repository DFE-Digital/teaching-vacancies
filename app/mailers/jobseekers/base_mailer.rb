class Jobseekers::BaseMailer < ApplicationMailer
  private

  def email_event
    @email_event ||= EmailEvent.new(@template, @to, uid, jobseeker: @jobseeker)
  end

  def email_event_prefix
    "jobseeker"
  end
end
