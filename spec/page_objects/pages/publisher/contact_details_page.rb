module PageObjects
  module Pages
    module Publisher
      class ContactDetailsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/contact_details"

        def fill_in_and_submit_form(contact_email, contact_number, other: true)
          if other
            choose I18n.t("helpers.label.publishers_job_listing_contact_details_form.contact_email_options.other")
            fill_in "publishers_job_listing_contact_details_form[other_contact_email]", with: contact_email
          else
            choose contact_email
          end

          choose I18n.t("helpers.label.publishers_job_listing_contact_details_form.contact_number_provided_options.#{contact_number.present?}")
          fill_in "publishers_job_listing_contact_details_form[contact_number]", with: contact_number

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
