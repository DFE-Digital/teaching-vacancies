module PageObjects
  module Pages
    module Publisher
      class JobRolePage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/job_role"

        def fill_in_and_submit_form(job_role)
          checkbox_label = I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}")
          find("label", text: checkbox_label, visible: true).click
          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
