module Jobseekers
  class SubscriptionMailer < BaseMailer
    def confirmation(subscription)
      subscription_email(subscription, "subscribed", "subscribed to")
    end

    def update(subscription)
      subscription_email(subscription, "updated", "updated")
    end

    private

    def subscription_email(subscription, action, action_desc)
      template = ERB.new(Rails.root.join("app/views/jobseekers/subscription_mailer/confirmation.text.erb").read)

      @filtered_search_criteria = SubscriptionPresenter.new(subscription).filtered_search_criteria

      template_mail("35ad9468-5042-439d-959d-3166325b265a",
                    to: subscription.email,
                    personalisation: {
                      subscription_link: new_subscription_url,
                      frequency: subscription.daily? ? "at the end of the day" : "weekly",
                      action: action,
                      action_description: action_desc,
                      jobseeker_missing_content: jobseeker_missing_content(subscription),
                      criteria_list: template.result(binding),
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

    def dfe_analytics_custom_data
      { subscription_identifier: @subscription_id }
    end

    def email_event_prefix
      "jobseeker_subscription"
    end
  end
end
