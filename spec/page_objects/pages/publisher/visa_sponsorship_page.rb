module PageObjects
  module Pages
    module Publisher
      class VisaSponsorshipPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/visa_sponsorship"

        def fill_in_and_submit_form(vacancy)
          choose I18n.t("helpers.label.publishers_job_listing_visa_sponsorship_form.visa_sponsorship_available_options.#{vacancy.visa_sponsorship_available}")

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
