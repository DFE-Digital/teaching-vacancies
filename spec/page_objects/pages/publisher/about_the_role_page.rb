module PageObjects
  module Pages
    module Publisher
      class AboutTheRolePage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/about_the_role"

        def fill_in_and_submit_form(vacancy)
          within ".ect-status-radios" do
            choose I18n.t("helpers.label.publishers_job_listing_about_the_role_form.ect_status_options.#{vacancy.ect_status}")
          end

          fill_in "publishers_job_listing_about_the_role_form[skills_and_experience]", with: vacancy.skills_and_experience
          fill_in "publishers_job_listing_about_the_role_form[school_offer]", with: vacancy.school_offer

          within ".flexi_working_details_provided" do
            choose I18n.t("helpers.label.publishers_job_listing_about_the_role_form.flexi_working_details_provided_options.#{vacancy.flexi_working_details_provided}")
          end
          fill_in "publishers_job_listing_about_the_role_form[flexi_working]", with: vacancy.flexi_working

          within ".further-details-provided-radios" do
            choose I18n.t("helpers.label.publishers_job_listing_about_the_role_form.further_details_provided_options.#{vacancy.further_details_provided}")
            fill_in "publishers_job_listing_about_the_role_form[further_details]", with: vacancy.further_details
          end

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
