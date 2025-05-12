# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        class CollectReferencesPage < CommonPage
          # set_url "/organisation/jobs/{vacancy_id}/job_applications/collect_references"
          set_url "/organisation/jobs/{vacancy_id}/job_application_batches/{job_application_batch_id}/references_and_declarations/collect_references"
          # organisation/jobs/:job_id/job_application_batches/:job_application_batch_id/references_and_declarations/:id
        end
      end
    end
  end
end
