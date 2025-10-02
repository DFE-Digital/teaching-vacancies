module PageObjects
  module Pages
    module Publisher
      class EducationPhasePage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/education_phases"

        def fill_in_and_submit_form(phase)
          check I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.#{phase}")
          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
