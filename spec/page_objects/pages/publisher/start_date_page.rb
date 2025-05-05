module PageObjects
  module Pages
    module Publisher
      class StartDatePage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/start_date"

        def fill_in_and_submit_form(starts_on = 35.days.from_now)
          choose I18n.t("helpers.legend.publishers_job_listing_start_date_form.start_date_specific")

          fill_in "publishers_job_listing_start_date_form[starts_on(3i)]", with: starts_on.day
          fill_in "publishers_job_listing_start_date_form[starts_on(2i)]", with: starts_on.month
          fill_in "publishers_job_listing_start_date_form[starts_on(1i)]", with: starts_on.year

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
