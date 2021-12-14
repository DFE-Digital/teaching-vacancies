class Jobseekers::BaseMailer < ApplicationMailer
  private

  def email_event
    @email_event ||= EmailEvent.new(template, to, uid, jobseeker: @jobseeker, ab_tests: ab_tests)
  end

  def ab_tests
    {}
  end

  def email_event_prefix
    "jobseeker"
  end
end
