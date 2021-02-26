module PageObjects
  module Jobseekers
    module JobApplications
      class Show < BaseReview
        set_url "/jobseekers/job_applications/{id}"
      end
    end
  end
end
