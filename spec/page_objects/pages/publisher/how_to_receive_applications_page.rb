module PageObjects
  module Pages
    module Publisher
      class HowToReceiveApplicationsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/how_to_receive_applications"

        def fill_in_and_submit_form(receive_applications)
          choose I18n.t("helpers.label.publishers_job_listing_how_to_receive_applications_form.receive_applications_options.#{receive_applications}")

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
