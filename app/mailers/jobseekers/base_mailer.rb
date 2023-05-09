class Jobseekers::BaseMailer < ApplicationMailer
  private

  def email_event
    @email_event ||= EmailEvent.new(template, to, uid, jobseeker: @jobseeker, ab_tests: ab_tests)
  end

  def dfe_analytics_email_event
    @dfe_analytics_email_event ||= DfE::Analytics::Event.new
      .with_type(email_event_type)
      .with_user(@jobseeker)
      .with_data(dfe_analytics_event_data)
  end

  def ab_tests
    {}
  end

  def email_event_prefix
    "jobseeker"
  end
end
