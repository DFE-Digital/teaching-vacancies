module Jobseekers
  class SubscriptionMailer < BaseMailer
    # Rate limit governance emails to comply with GOV.UK Notify sending limits
    limit_method :governance_email,
                 rate: GOVUK_NOTIFY_SEND_LIMIT_PER_MINUTE / SIDEKIQ_WORKER_COUNT,
                 balanced: false

    def confirmation(subscription)
      subscription_email(subscription, "subscribed", "subscribed to")
    end

    def update(subscription)
      subscription_email(subscription, "updated", "updated")
    end

    def governance_email_registered_never_updated(subscription)
      governance_email(subscription, registered: true, never_updated: true)
    end

    def governance_email_registered_was_updated(subscription)
      governance_email(subscription, registered: true, never_updated: false)
    end

    def governance_email_unregistered_never_updated(subscription)
      governance_email(subscription, registered: false, never_updated: true)
    end

    def governance_email_unregistered_was_updated(subscription)
      governance_email(subscription, registered: false, never_updated: false)
    end

    private

    def subscription_email(subscription, action, action_desc)
      @filtered_search_criteria = SubscriptionPresenter.new(subscription).filtered_search_criteria
      criteria_list = @filtered_search_criteria.map { |filter, value| "- #{filter.humanize}: #{value}" }.join("\n")

      template_mail("35ad9468-5042-439d-959d-3166325b265a",
                    to: subscription.email,
                    personalisation: {
                      subscription_link: new_subscription_url,
                      frequency: subscription.daily? ? "at the end of the day" : "weekly",
                      action: action,
                      action_description: action_desc,
                      jobseeker_missing_content: jobseeker_missing_content(subscription),
                      criteria_list: criteria_list,
                      unsubscribe_link: unsubscribe_subscription_url(subscription.token),
                      home_page_link: root_url,
                    })
      # for the DfeAnalytics data
      @subscription_id = subscription.id
    end

    def jobseeker_missing_content(subscription)
      if Jobseeker.exists?(email: subscription.email.downcase)
        ""
      else
        text = t("jobseekers.subscription_mailer.confirmation.create_account.link")
        url = new_jobseeker_session_url
        @sign_up_link = "[#{text}](#{url})"
        jobseeker_template = ERB.new(Rails.root.join("app/views/jobseekers/subscription_mailer/jobseeker_missing.text.erb").read)
        jobseeker_template.result(binding)
      end
    end

    def governance_email(subscription, registered:, never_updated:)
      @filtered_search_criteria = SubscriptionPresenter.new(subscription).filtered_search_criteria
      @subscription_id = subscription.id

      template_id = governance_template_id(registered, never_updated)
      personalisation = governance_personalisation(subscription, registered, never_updated)

      template_mail(template_id, to: subscription.email, personalisation: personalisation)
    end

    def governance_template_id(registered, never_updated)
      case [registered, never_updated]
      when [true, true]   then "18bc8ad4-007a-4347-99da-c67b0e471bd0"  # Registered, Created
      when [true, false]  then "e2bd00b4-3a12-4ab4-86a9-424d1d780bf2"  # Registered, Updated
      when [false, true]  then "07f84d0f-300e-4843-a135-8830e86a53b1"  # Unregistered, Created
      else "a8777937-fc89-495f-a196-b4242eec0193" # Unregistered, Updated
      end
    end

    def governance_personalisation(subscription, registered, never_updated)
      reference_date = never_updated ? subscription.created_at : subscription.updated_at
      campaign_params = { utm_source: uid, utm_medium: "email", utm_campaign: "subscription_governance" }
      criteria_list = @filtered_search_criteria.map { |filter, value| "- #{filter.humanize}: #{value}" }.join("\n")

      personalisation = {
        alert_date: reference_date.strftime("%-d %B %Y"),
        criteria_list: criteria_list,
        keep_job_alert_url: keep_subscription_url(subscription.token, **campaign_params),
        deletion_date: 1.month.from_now.strftime("%-d %B %Y"),
        unsubscribe_link: unsubscribe_subscription_url(subscription.token, **campaign_params),
      }

      personalisation[:sign_in_url] = new_jobseeker_session_url if registered
      personalisation
    end

    def dfe_analytics_custom_data
      { subscription_identifier: @subscription_id }
    end

    def email_event_prefix
      "jobseeker_subscription"
    end
  end
end
