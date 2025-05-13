module PageObjects
  module Pages
    module Publisher
      class SubjectsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/subjects"

        def fill_in_and_submit_form(subjects)
          subjects&.each do |subject|
            check subject,
                  name: "publishers_job_listing_subjects_form[subjects][]",
                  visible: false
          end

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
