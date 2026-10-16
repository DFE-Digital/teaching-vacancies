module PageObjects
  module Pages
    module Publisher
      class ContractInformationPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/contract_information"

        def fill_in_and_submit_form(working_patterns:, is_job_share:, working_patterns_details:, contract_type: "fixed_term", contract_length: "1 month")
          if contract_type == "fixed_term"
            choose I18n.t("helpers.label.publishers_job_listing_contract_information_form.contract_type_options.fixed_term")
            # Choose "Yes" for parental leave coverage
            within "#publishers-job-listing-contract-information-form-contract-type-fixed-term-conditional" do
              choose "Yes"
            end
            fill_in "Length of contract", with: contract_length
          else
            choose I18n.t("helpers.label.publishers_job_listing_contract_information_form.contract_type_options.#{contract_type}")
          end

          working_patterns.each do |working_pattern|
            check Vacancy.human_attribute_name(working_pattern.to_s), name: "publishers_job_listing_contract_information_form[working_patterns][]"
          end

          # Choose "Yes" or "No" for job share option
          job_share_label = "publishers-job-listing-contract-information-form-is-job-share-#{is_job_share}-field"
          find("label[for=#{job_share_label}]").click

          fill_in "publishers_job_listing_contract_information_form[working_patterns_details]", with: working_patterns_details

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
