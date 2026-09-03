# frozen_string_literal: true

# Tracks one nightly DSI sync (the users/approvers BigQuery exports, or the db_sync of
# publishers into our own database) as it fans out across per-page jobs. For the BigQuery
# exports, the live table is only replaced once every page has been fetched successfully:
# see FetchDSIUsersExportPageJob / FinalizeDSIUsersExportJob. For db_sync there's no
# destructive step to guard, so this only provides the overlap guard and stale-run
# monitoring: see UpdateDSIUsersInDbJob / FetchDSIUsersPageJob.
class DSIExportRun < ApplicationRecord
  SOURCES = %w[users approvers db_sync].freeze

  has_many :dsi_export_run_pages, dependent: :destroy

  enum :status, { running: 0, finalizing: 1, completed: 2, failed: 3 }

  validates :source, inclusion: { in: SOURCES }
  validates :total_pages, numericality: { greater_than: 0, only_integer: true }

  def all_pages_received?
    dsi_export_run_pages.count == total_pages
  end
end
