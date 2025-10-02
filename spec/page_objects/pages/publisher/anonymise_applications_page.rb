module PageObjects
  module Pages
    module Publisher
      class AnonymiseApplicationsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/anonymise_applications"

        element :anonymous_option, "label[for='publishers-job-listing-anonymise-applications-form-anonymise-applications-true-field']"
        element :standard_option, "label[for='publishers-job-listing-anonymise-applications-form-anonymise-applications-false-field']"
      end
    end
  end
end
