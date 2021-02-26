module PageObjects
  module Jobseekers
    module JobApplications
      class Review < BaseReview
        set_url "jobseekers/job_applications{/job_application_id}/review"
      end
    end
  end
end
