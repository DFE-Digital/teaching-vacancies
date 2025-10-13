# frozen_string_literal: true

module Publishers
  module Vacancies
    class BaseController < Publishers::BaseController
      helper_method :vacancy, :vacancies

      private

      def vacancy
        # Scope to internal vacancies to disallow editing of external ones

        # As the vacancy is not associated with an organisation upon creation, calling the vacancies method will return an empty array as an organisation is not associated
        # with it. To fix this, before the vacancy's status is set (and therefore before an organisation is associated), we find the job from the vacancies where status is nil.
        @vacancy ||= vacancies.internal.find_by(id: params[:job_id].presence || params[:id]) || DraftVacancy.find(params[:job_id].presence || params[:id])
      end

      def vacancies
        @vacancies ||= current_organisation.all_vacancies
      end

      def update_google_index(job)
        url = job_url(job)
        UpdateGoogleIndexQueueJob.perform_later(url)
      end
    end
  end
end
