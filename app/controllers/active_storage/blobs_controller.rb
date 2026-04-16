# frozen_string_literal: true

# Override ActiveStorage's BlobsController to prevent downloading files that have not been confirmed clean by the antivirus scan
class ActiveStorage::BlobsController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob

  before_action :redirect_unless_blob_safe, only: :show # rubocop:disable Rails/LexicallyScopedActionFilter

  private

  def redirect_unless_blob_safe
    unless @blob.malware_scan_clean?
      redirect_to root_path, alert: t("active_storage.blobs.file_unavailable")
    end
  end
end
