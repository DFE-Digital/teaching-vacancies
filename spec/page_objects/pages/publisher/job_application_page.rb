# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      class JobApplicationPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/job_applications/{job_application_id}"
      end
    end
  end
end
