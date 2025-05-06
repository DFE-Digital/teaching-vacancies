# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        class ReferencePage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/{job_application_id}/references/{reference_id}"
        end
      end
    end
  end
end
