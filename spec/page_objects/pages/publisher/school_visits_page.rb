module PageObjects
  module Pages
    module Publisher
      class SchoolVisitsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/school_visits"

        def fill_in_and_submit_form(vacancy)
          choose I18n.t("helpers.label.publishers_job_listing_school_visits_form.school_visits_options.#{vacancy.school_visits}")

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
