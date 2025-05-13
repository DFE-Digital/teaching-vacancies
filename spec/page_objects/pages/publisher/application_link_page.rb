module PageObjects
  module Pages
    module Publisher
      class ApplicationLinkPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/application_link"

        def fill_in_and_submit_form(vacancy)
          fill_in "publishers_job_listing_application_link_form[application_link]", with: vacancy.application_link

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
