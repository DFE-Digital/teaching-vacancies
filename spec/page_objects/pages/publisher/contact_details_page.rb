module PageObjects
  module Pages
    module Publisher
      class ContactDetailsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/contact_details"

        def fill_in_and_submit_form(vacancy)
          choose I18n.t("helpers.label.publishers_job_listing_contact_details_form.contact_email_options.other")
          fill_in "publishers_job_listing_contact_details_form[other_contact_email]", with: vacancy.contact_email

          choose I18n.t("helpers.label.publishers_job_listing_contact_details_form.contact_number_provided_options.#{vacancy.contact_number_provided}")
          fill_in "publishers_job_listing_contact_details_form[contact_number]", with: vacancy.contact_number

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
