module PageObjects
  module Pages
    module Publisher
      class ConfirmContactDetailsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/confirm_contact_details"

        def fill_in_and_submit_form
          choose I18n.t("helpers.label.publishers_job_listing_confirm_contact_details_form.confirm_contact_email_options.true")

          click_on I18n.t("buttons.save_and_continue")
        end

        def click_change_email_button
          click_on "Go back to change the email"
        end
      end
    end
  end
end
