# frozen_string_literal: true

# One page of DSI data fetched during a DSIExportRun, cached here until every page has
# arrived and the run can be finalized. See FinalizeDSIUsersExportJob.
class DSIExportRunPage < ApplicationRecord
  belongs_to :dsi_export_run

  validates :page_number, presence: true, uniqueness: { scope: :dsi_export_run_id }
  # Not `presence: true`: an empty array is a legitimate payload (see FetchDSIUsersPageJob,
  # which has nothing worth caching per page), so only nil itself should be rejected.
  validates :payload, exclusion: { in: [nil] }
end
