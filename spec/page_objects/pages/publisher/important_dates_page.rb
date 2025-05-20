module PageObjects
  module Pages
    module Publisher
      class ImportantDatesPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/important_dates"

        def fill_in_and_submit_form(publish_on:, expires_at:)
          choose I18n.t("helpers.label.publishers_job_listing_important_dates_form.publish_on_day_options.another_day")

          fill_in "publishers_job_listing_important_dates_form[publish_on(3i)]", with: publish_on.day
          fill_in "publishers_job_listing_important_dates_form[publish_on(2i)]", with: publish_on.month
          fill_in "publishers_job_listing_important_dates_form[publish_on(1i)]", with: publish_on.year

          fill_in "publishers_job_listing_important_dates_form[expires_at(3i)]", with: expires_at.day
          fill_in "publishers_job_listing_important_dates_form[expires_at(2i)]", with: expires_at.month
          fill_in "publishers_job_listing_important_dates_form[expires_at(1i)]", with: expires_at.year

          choose "9am", name: "publishers_job_listing_important_dates_form[expiry_time]"

          click_on I18n.t("buttons.save_and_continue")
        end

        element :change_publish_day_field, "#publishers_job_listing_important_dates_form_publish_on_3i"
      end
    end
  end
end
