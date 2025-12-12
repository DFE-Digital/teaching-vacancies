module PageObjects
  module Pages
    module Publisher
      class ConfirmContactDetailsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/confirm_contact_details"

        def fill_in_and_submit_form
          click_on I18n.t("buttons.save_and_continue")
        end

        def click_change_email_link
          click_link "Change contact details"
        end
      end
    end
  end
end
