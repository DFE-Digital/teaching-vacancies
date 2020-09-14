class NqtJobAlertsController < ApplicationController
  include ParameterSanitiser

  def new
    @nqt_job_alerts_form = NqtJobAlertsForm.new(nqt_job_alerts_params)
  end

  def create
    @nqt_job_alerts_form = NqtJobAlertsForm.new(nqt_job_alerts_params)
    subscription = Subscription.new(@nqt_job_alerts_form.job_alert_params)
    @subscription = SubscriptionPresenter.new(subscription)

    recaptcha_valid = verify_recaptcha(model: subscription, action: 'subscription')
    subscription.recaptcha_score = recaptcha_reply['score'] if recaptcha_valid && recaptcha_reply

    if @nqt_job_alerts_form.valid?
      subscription.save
      AuditSubscriptionCreationJob.perform_later(@subscription.to_row)
      SubscriptionMailer.confirmation(subscription.id).deliver_later
      render :confirm
    else
      render :new
    end
  end

private

  def nqt_job_alerts_params
    ParameterSanitiser.call(params[:nqt_job_alerts_form] || params).permit(:keywords, :location, :email)
  end
end
