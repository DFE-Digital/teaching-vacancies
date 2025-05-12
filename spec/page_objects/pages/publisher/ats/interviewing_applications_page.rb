# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        class InterviewingApplicationsPage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications#interviewing"

          elements :pre_interview_check_links, ".application-interviewing td:nth-child(4) a"
        end
      end
    end
  end
end
