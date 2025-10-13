class SubscriptionsController < ApplicationController
  include ReturnPathTracking
  include RecaptchaChecking

  self.authentication_scope = :jobseeker

  before_action :trigger_create_job_alert_clicked_event, only: :new, if: -> { vacancy_id.present? }

  def new
    @point_coordinates = params[:coordinates_present] == "true"
    @ect_job_alert = params[:ect_job_alert]
    session[:subscription_autopopulated] = params[:search_criteria].present?
    @form = Jobseekers::SubscriptionForm.new(new_form_attributes)
    @organisation = Organisation.friendly.find(search_criteria_params[:organisation_slug]) if organisation_job_alert?

    render("subscriptions/campaign/new", layout: "subscription_campaign") if campaign_link?
  end

  def create
    @form = Jobseekers::SubscriptionForm.new(subscription_params)

    if @form.invalid?
      @form.campaign.present? ? render("subscriptions/campaign/new", layout: "subscription_campaign") : render(:new)
    else
      recaptcha_protected(form: @form) do
        subscription = Jobseekers::CreateSubscription.new(@form, recaptcha_reply&.score).call
        trigger_subscription_event(:job_alert_subscription_created, subscription)
        @subscription = SubscriptionPresenter.new(subscription)
        if jobseeker_signed_in?
          redirect_to jobseekers_subscriptions_path, success: t(".success")
        else
          @jobseeker = Jobseeker.find_by(email: subscription.email.downcase)
          store_return_location(jobseekers_subscriptions_path)
          render :confirm
        end
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
      @subscription = SubscriptionPresenter.new(subscription)
      notify_and_redirect subscription
    else
      @form = Jobseekers::SubscriptionForm.new(subscription_params)
      @subscription = SubscriptionPresenter.new(subscription)

      if @form.valid?
        subscription.update_with_search_criteria(@form.job_alert_params)
        notify_and_redirect subscription
      else
        render :edit
      end
    end
  end

  def unsubscribe
    subscription = Subscription.kept.find_and_verify_by_token(token)

    @subscription = SubscriptionPresenter.new(subscription)
  end

  def destroy
    subscription = Subscription.kept.find_and_verify_by_token(token)

    trigger_subscription_event(:job_alert_subscription_unsubscribed, subscription)
    # will be destroyed tomorrow morning by RemoveInvalidSubscriptionsJob
    # just keeping around long enough to collect feedback
    subscription.discard

    redirect_to new_subscription_unsubscribe_feedback_path(subscription)
  end

  private

  def campaign_link?
    params[:email_contact].present?
  end

  # There are mailing campaigns using Mailchimp to send "Subscribe to our job alerts" emails to user groups.
  # These emails links to our service contain parameters in their URL, which values are used to pre-populate the
  # subscription form fields.
  # Some fields have default values unless explicitly set by a parameter.
  def campaign_attributes
    campaign = campaign_params
    {
      campaign: true,
      subjects: ([campaign[:email_subject].capitalize] if campaign[:email_subject].present?),
      phases: ([campaign[:email_phase]] if campaign[:email_phase].present?),
      location: campaign[:email_postcode].presence,
      radius: campaign[:email_radius].presence || "15",
      teaching_job_roles: (campaign[:email_jobrole].present? ? [campaign[:email_jobrole]] : ["teacher"]),
      ect_statuses: (campaign[:email_ect].present? ? [campaign[:email_ect]] : ["ect_suitable"]),
      working_patterns: (campaign[:email_working_pattern].present? ? [campaign[:email_working_pattern]] : ["full_time"]),
      email: campaign[:email_contact].presence,
      user_name: campaign[:email_name].presence,
    }.compact
  end

  def new_form_attributes
    if params[:search_criteria].present?
      search_criteria_params
    elsif campaign_link?
      email.merge(campaign_attributes)
    else
      email
    end
  end

  def trigger_create_job_alert_clicked_event
    trigger_dfe_analytics_event(:vacancy_create_job_alert_clicked, data: { vacancy_id: vacancy_id })
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
      data: {
        autopopulated: session.delete(:subscription_autopopulated),
        frequency: subscription.frequency,
        recaptcha_score: subscription.recaptcha_score,
        search_criteria: subscription.search_criteria,
        subscription_identifier: subscription.id,
      },
      hidden_data: {
        email_identifier: subscription.email,
      },

    }

    trigger_dfe_analytics_event(type, event_data)
  end

  def email
    params.permit(:email)
  end

  def campaign_params
    params.permit(:email_name, :email_subject, :email_phase, :email_postcode, :email_jobrole, :email_radius, :email_ect,
                  :email_working_pattern, :email_contact)
  end

  def search_criteria_params
    params.expect(search_criteria: [:keyword,
                                    :location,
                                    :organisation_slug,
                                    :radius,
                                    { teaching_job_roles: [], support_job_roles: [], ect_statuses: [], subjects: [], phases: [], working_patterns: [], visa_sponsorship_availability: [] }])
  end

  def subscription_params
    params.expect(jobseekers_subscription_form: [:email,
                                                 :frequency,
                                                 :keyword,
                                                 :location,
                                                 :organisation_slug,
                                                 :radius,
                                                 :campaign,
                                                 :user_name,
                                                 { teaching_job_roles: [],
                                                   support_job_roles: [],
                                                   visa_sponsorship_availability: [],
                                                   ect_statuses: [],
                                                   subjects: [],
                                                   phases: [],
                                                   working_patterns: [] }])
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
      @jobseeker = Jobseeker.find_by(email: subscription.email.downcase)
      store_return_location(jobseekers_subscriptions_path)
      render :confirm
    end
  end

  def organisation_job_alert?
    params[:search_criteria] && search_criteria_params[:organisation_slug].present?
  end
end
