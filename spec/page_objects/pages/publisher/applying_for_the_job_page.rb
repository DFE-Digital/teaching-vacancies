module PageObjects
  module Pages
    module Publisher
      class ApplyingForTheJobPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/applying_for_the_job"

        element :standard_option, "label[for='publishers-job-listing-applying-for-the-job-form-application-form-type-no-religion-field']"
        element :catholic_option, 'label[for="publishers-job-listing-applying-for-the-job-form-application-form-type-catholic-field"]'

        def fill_in_and_submit_form
          choose I18n.t("helpers.label.publishers_job_listing_applying_for_the_job_form.application_form_type_options.other")

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
