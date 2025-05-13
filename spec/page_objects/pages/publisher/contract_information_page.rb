module PageObjects
  module Pages
    module Publisher
      class ContractInformationPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/contract_information"

        def fill_in_and_submit_form(vacancy, contract_type = "fixed_term")
          if contract_type == "fixed_term"
            choose I18n.t("helpers.label.publishers_job_listing_contract_information_form.contract_type_options.fixed_term")
            # Choose "Yes" for parental leave coverage
            within "#publishers-job-listing-contract-information-form-contract-type-fixed-term-conditional" do
              choose "Yes"
            end
            fill_in "Length of contract", with: "1 month"
          else
            choose I18n.t("helpers.label.publishers_job_listing_contract_information_form.contract_type_options.#{contract_type}")
          end

          vacancy.working_patterns.each do |working_pattern|
            check Vacancy.human_attribute_name(working_pattern.to_s), name: "publishers_job_listing_contract_information_form[working_patterns][]"
          end

          # Choose "Yes" or "No" for job share option
          job_share_label = "publishers-job-listing-contract-information-form-is-job-share-#{vacancy.is_job_share}-field"
          find("label[for=#{job_share_label}]").click

          fill_in "publishers_job_listing_contract_information_form[working_patterns_details]", with: vacancy.working_patterns_details

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
