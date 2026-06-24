module PageObjects
  module Pages
    module Publisher
      class ConfirmJobAddressPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/confirm_job_address"

        def fill_in_and_submit_form(line1: "", line2: "", town: "", county: "", postcode: "")
          fill_in "publishers_job_listing_confirm_job_address_form[job_address_line1]", with: line1
          fill_in "publishers_job_listing_confirm_job_address_form[job_address_line2]", with: line2
          fill_in "publishers_job_listing_confirm_job_address_form[job_address_town]", with: town
          fill_in "publishers_job_listing_confirm_job_address_form[job_address_county]", with: county
          fill_in "publishers_job_listing_confirm_job_address_form[job_address_postcode]", with: postcode
          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
