class SubscriptionsController < ApplicationController
  include ReturnPathTracking
  self.authentication_scope = :jobseeker

  before_action :trigger_create_job_alert_clicked_event, only: :new, if: -> { vacancy_id.present? }

  def new
    @point_coordinates = params[:coordinates_present] == "true"
    @ect_job_alert = params[:ect_job_alert]
    session[:subscription_autopopulated] = params[:search_criteria].present?
    @form = Jobseekers::SubscriptionForm.new(params[:search_criteria].present? ? search_criteria_params : email)
    @organisation = Organisation.friendly.find(search_criteria_params[:organisation_slug]) if organisation_job_alert?
  end

  def create
    @form = Jobseekers::SubscriptionForm.new(subscription_params)
    subscription = Subscription.new(@form.job_alert_params)
    @subscription = SubscriptionPresenter.new(subscription)

    if @form.invalid?
      render :new
    elsif recaptcha_is_invalid?
      redirect_to invalid_recaptcha_path(form_name: subscription.class.name.underscore.humanize)
    else
      notify_new_subscription(subscription)

      if jobseeker_signed_in?
        redirect_to jobseekers_subscriptions_path, success: t(".success")
      else
        @jobseeker = Jobseeker.find_by(email: subscription.email)
        store_return_location(jobseekers_subscriptions_path)
        render :confirm
      end
    end
  end

  def edit
    @subscription = Subscription.find_and_verify_by_token(token)
    @organisation = @subscription.organisation
    @form = Jobseekers::SubscriptionForm.new(@subscription)
  end

  def update
    subscription = Subscription.find_and_verify_by_token(token)

    if updating_frequency?
      subscription.update(frequency: params.dig(:subscription, :frequency))
      notify_and_redirect subscription
    else
      @form = Jobseekers::SubscriptionForm.new(subscription_params)
      @subscription = SubscriptionPresenter.new(subscription)

      if @form.valid?
        subscription.update(@form.job_alert_params)
        notify_and_redirect subscription
      else
        render :edit
      end
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

  def notify_new_subscription(subscription)
    subscription.update(recaptcha_score: recaptcha_reply&.dig("score"))
    Jobseekers::SubscriptionMailer.confirmation(subscription.id).deliver_later
    trigger_subscription_event(:job_alert_subscription_created, subscription)
  end

  def trigger_create_job_alert_clicked_event
    request_event.trigger(:vacancy_create_job_alert_clicked, vacancy_id: StringAnonymiser.new(vacancy_id))
    trigger_dfe_analytics_event(:vacancy_create_job_alert_clicked, { vacancy_id: StringAnonymiser.new(vacancy_id) })
  end

  def trigger_dfe_analytics_event(type, data)
    fail_safe do
      event = DfE::Analytics::Event.new
        .with_type(type)
        .with_request_details(request)
        .with_response_details(response)
        .with_user(current_jobseeker)
        .with_data(data)

      DfE::Analytics::SendEvents.do([event])
    end
  end

  def trigger_subscription_event(type, subscription)
    event_data = {
      autopopulated: session.delete(:subscription_autopopulated),
      email_identifier: StringAnonymiser.new(subscription.email).to_s,
      frequency: subscription.frequency,
      recaptcha_score: subscription.recaptcha_score,
      search_criteria: subscription.search_criteria,
      subscription_identifier: subscription.id,
    }

    request_event.trigger(type, event_data)
    trigger_dfe_analytics_event(type, event_data)
  end

  def email
    params.permit(:email)
  end

  def search_criteria_params
    params.require(:search_criteria)
          .permit(:keyword, :location, :organisation_slug, :radius, job_roles: [], ect_statuses: [], subjects: [], phases: [], working_patterns: [])
  end

  def subscription_params
    params.require(:jobseekers_subscription_form)
          .permit(:email, :frequency, :keyword, :location, :organisation_slug, :radius, job_roles: [], ect_statuses: [], subjects: [], phases: [], working_patterns: [])
  end

  def token
    params.require(:id)
  end

  def vacancy_id
    params.permit(:vacancy_id)[:vacancy_id]
  end

  def updating_frequency?
    params[:subscription].present?
  end

  def notify_and_redirect(subscription)
    Jobseekers::SubscriptionMailer.update(subscription.id).deliver_later
    trigger_subscription_event(:job_alert_subscription_updated, subscription)

    if jobseeker_signed_in?
      redirect_to jobseekers_subscriptions_path, success: t(".success")
    else
      @jobseeker = Jobseeker.find_by(email: subscription.email)
      store_return_location(jobseekers_subscriptions_path)
      render :confirm
    end
  end

  def organisation_job_alert?
    params[:search_criteria] && search_criteria_params[:organisation_slug].present?
  end
end
