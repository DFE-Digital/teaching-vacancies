class Jobseekers::CreateSubscription
  attr_reader :form, :recaptcha_score

  def initialize(form, recaptcha_score)
    @form = form
    @recaptcha_score = recaptcha_score
  end

  def call
    Subscription.create!(form.job_alert_params.merge(recaptcha_score: recaptcha_score)).tap do |subscription|
      SetSubscriptionLocationDataJob.perform_later(subscription)
      Jobseekers::SubscriptionMailer.confirmation(subscription).deliver_later
    end
  end
end
