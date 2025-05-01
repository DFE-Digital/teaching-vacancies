# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      class JobTitlePage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/job_title"
      end
    end
  end
end
