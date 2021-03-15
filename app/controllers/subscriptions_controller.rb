class SubscriptionsController < ApplicationController
  before_action :track_origin_and_trigger_event, only: :new

  def new
    @point_coordinates = params[:coordinates_present] == "true"
    @subscription_form = Jobseekers::SubscriptionForm.new(params[:search_criteria].present? ? search_criteria_params : email)
  end

  def create
    @subscription_form = Jobseekers::SubscriptionForm.new(subscription_params)
    subscription = Subscription.new(@subscription_form.job_alert_params)
    @subscription = SubscriptionPresenter.new(subscription)

    if @subscription_form.invalid?
      render :new
    elsif recaptcha_is_invalid?(subscription)
      redirect_to invalid_recaptcha_path(form_name: subscription.class.name.underscore.humanize)
    else
      subscription.recaptcha_score = recaptcha_reply&.dig("score")
      subscription.save
      Jobseekers::SubscriptionMailer.confirmation(subscription.id).deliver_later
      trigger_subscription_event(:job_alert_subscription_created, subscription)

      if jobseeker_signed_in?
        redirect_to jobseekers_subscriptions_path, success: t(".success")
      else
        @jobseeker = Jobseeker.find_by(email: subscription.email)
        render :confirm
      end
    end
  end

  def edit
    @subscription = Subscription.find_and_verify_by_token(token)
    @subscription_form = Jobseekers::SubscriptionForm.new(@subscription)
  end

  def update
    subscription = Subscription.find_and_verify_by_token(token)
    @subscription_form = Jobseekers::SubscriptionForm.new(subscription_params)
    @subscription = SubscriptionPresenter.new(subscription)

    if @subscription_form.valid?
      subscription.update(@subscription_form.job_alert_params)
      Jobseekers::SubscriptionMailer.update(subscription.id).deliver_later
      trigger_subscription_event(:job_alert_subscription_updated, subscription)

      if jobseeker_signed_in?
        redirect_to jobseekers_subscriptions_path, success: t(".success")
      else
        @jobseeker = Jobseeker.find_by(email: subscription.email)
        render :confirm
      end
    else
      render :edit
    end
  end

  def unsubscribe
    subscription = Subscription.find_and_verify_by_token(token)
    raise ActiveRecord::RecordNotFound unless subscription.active?

    @subscription = SubscriptionPresenter.new(subscription)
  end

  def destroy
    subscription = Subscription.find_and_verify_by_token(token)
    raise ActiveRecord::RecordNotFound unless subscription.active?

    trigger_subscription_event(:job_alert_subscription_unsubscribed, subscription)
    subscription.unsubscribe

    redirect_to new_subscription_unsubscribe_feedback_path(subscription)
  end

  private

  def track_origin_and_trigger_event
    return unless origin_param&.start_with?(%r{/\w})

    @origin = origin_param
    session[:subscription_origin] = @origin
    vacancy = Vacancy.find_by_slug(origin_param.split("/").last)
    return unless vacancy

    request_event.trigger(:vacancy_create_job_alert_clicked, vacancy_id: vacancy.id)
  end

  def trigger_subscription_event(type, subscription)
    request_event.trigger(
      type,
      subscription_identifier: StringAnonymiser.new(subscription.id),
      email_identifier: StringAnonymiser.new(subscription.email),
      recaptcha_score: subscription.recaptcha_score,
      frequency: subscription.frequency,
      search_criteria: subscription.search_criteria,
      origin: session.delete(:subscription_origin),
    )
  end

  def email
    params.permit(:email)
  end

  def origin_param
    params.permit(:origin)[:origin]
  end

  def search_criteria_params
    params.require(:search_criteria)
          .permit(:keyword, :location, :radius, job_roles: [], phases: [], working_patterns: [])
  end

  def subscription_params
    params.require(:jobseekers_subscription_form)
          .permit(:email, :frequency, :keyword, :location, :radius, job_roles: [], phases: [], working_patterns: [])
  end

  def token
    params.require(:id)
  end
end
