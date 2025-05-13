module PageObjects
  module Pages
    module Publisher
      class JobTitlePage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/job_title"

        def fill_in_and_submit_form(job_title)
          fill_in "publishers_job_listing_job_title_form[job_title]", with: job_title
          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
