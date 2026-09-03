# frozen_string_literal: true

# One page of DSI data fetched during a DSIExportRun, cached here until every page has
# arrived and the run can be finalized. See FinalizeDSIUsersExportJob.
class DSIExportRunPage < ApplicationRecord
  belongs_to :dsi_export_run

  validates :page_number, presence: true, uniqueness: { scope: :dsi_export_run_id }
  # Not `presence: true`: an empty array is a legitimate payload (see FetchDSIUsersPageJob,
  # which has nothing worth caching per page), so only nil itself should be rejected. Not
  # `exclusion: { in: [nil] }` either: ActiveModel's Clusivity module checks an Array-typed
  # value element-by-element against the exclusion list, so `[]` vacuously satisfies `all?`
  # and gets wrongly treated as excluded. See .database_consistency.yml for the matching
  # NullConstraintChecker override, since it only recognises the validator kinds above.
  validate :payload_is_not_nil

  private

  def payload_is_not_nil
    errors.add(:payload, :blank) if payload.nil?
  end
end
