# frozen_string_literal: true

module Publishers
  module Vacancies
    class BulkShortlistingMessagesController < BulkMessagesController
      def finish_wizard_path
        organisation_job_job_applications_path(vacancy.id, anchor: :shortlisted)
      end
    end
  end
end
