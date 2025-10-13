class Jobseekers::CreateSubscription
  attr_reader :form, :recaptcha_score

  def initialize(form, recaptcha_score)
    @form = form
    @recaptcha_score = recaptcha_score
  end

  def call
    subscription = Subscription.new(form.job_alert_params)
    subscription.recaptcha_score = recaptcha_score
    subscription.save!
    SetSubscriptionLocationDataJob.perform_later(subscription.id)
    Jobseekers::SubscriptionMailer.confirmation(subscription.id).deliver_later
    subscription
  end
end
