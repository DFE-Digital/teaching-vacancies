class NqtJobAlertsController < ApplicationController
  def new
    @nqt_job_alerts_form = Jobseekers::NqtJobAlertsForm.new(nqt_job_alerts_params)
  end

  def create
    @nqt_job_alerts_form = Jobseekers::NqtJobAlertsForm.new(nqt_job_alerts_params)
    subscription = Subscription.new(@nqt_job_alerts_form.job_alert_params)
    @subscription = SubscriptionPresenter.new(subscription)

    if @nqt_job_alerts_form.invalid?
      render :new
    elsif recaptcha_is_invalid?(subscription)
      redirect_to invalid_recaptcha_path(form_name: @nqt_job_alerts_form.class.name.underscore.humanize)
    else
      subscription.recaptcha_score = recaptcha_reply["score"]
      subscription.save
      Jobseekers::SubscriptionMailer.confirmation(subscription.id).deliver_later
      trigger_subscription_created_event(subscription)
      render :confirm
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
    (params[:jobseekers_nqt_job_alerts_form] || params).permit(:keywords, :location, :email)
  end
end
