class NqtJobAlertsController < ApplicationController
  include ParameterSanitiser

  def new
    @nqt_job_alerts_form = Jobseekers::NqtJobAlertsForm.new(nqt_job_alerts_params)
  end

  def create
    @nqt_job_alerts_form = Jobseekers::NqtJobAlertsForm.new(nqt_job_alerts_params)
    subscription = Subscription.new(@nqt_job_alerts_form.job_alert_params)
    @subscription = SubscriptionPresenter.new(subscription)

    recaptcha_is_valid = verify_recaptcha(model: subscription, action: "subscription")
    subscription.recaptcha_score = recaptcha_reply["score"] if recaptcha_is_valid && recaptcha_reply

    if recaptcha_is_valid && recaptcha_reply && invalid_recaptcha_score?
      redirect_to invalid_recaptcha_path(form_name: @nqt_job_alerts_form.class.name.underscore)
    elsif @nqt_job_alerts_form.valid?
      subscription.save
      SubscriptionMailer.confirmation(subscription.id).deliver_later
      trigger_subscription_created_event(subscription)
      render :confirm
    else
      render :new
    end
  end

  private

  def trigger_subscription_created_event(subscription)
    request_event.trigger(
      :job_alert_subscription_created,
      subscription_identifier: StringAnonymiser.new(subscription.id),
      email_identifier: StringAnonymiser.new(subscription.email),
      recaptcha_score: subscription.recaptcha_score,
      frequency: subscription.frequency,
      search_criteria: subscription.search_criteria,
    )
  end

  def nqt_job_alerts_params
    ParameterSanitiser.call(params[:jobseekers_nqt_job_alerts_form] || params).permit(:keywords, :location, :email)
  end
end
