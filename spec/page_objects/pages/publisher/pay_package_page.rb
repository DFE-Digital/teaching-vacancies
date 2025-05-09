module PageObjects
  module Pages
    module Publisher
      class PayPackagePage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/pay_package"

        def fill_in_and_submit_form(vacancy)
          if vacancy.contract_type == "casual"
            check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.hourly_rate")
            fill_in "publishers_job_listing_pay_package_form[salary]", with: vacancy.hourly_rate
          else
            check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.full_time")
            fill_in "publishers_job_listing_pay_package_form[salary]", with: vacancy.salary

            if vacancy.working_patterns.include? "part_time"
              check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.part_time")
              fill_in "publishers_job_listing_pay_package_form[actual_salary]", with: vacancy.actual_salary
            end

            check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.pay_scale")
            fill_in "publishers_job_listing_pay_package_form[pay_scale]", with: vacancy.pay_scale
          end

          choose I18n.t("helpers.label.publishers_job_listing_pay_package_form.benefits_options.true")
          fill_in "publishers_job_listing_pay_package_form[benefits_details]", with: vacancy.benefits_details

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
