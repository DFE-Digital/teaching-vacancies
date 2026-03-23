# frozen_string_literal: true

# Override ActiveStorage's BlobsController to add malware scan checks
class ActiveStorage::BlobsController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob

  before_action :verify_blob_scan_status

  def show
    expires_in ActiveStorage.service_urls_expire_in
    redirect_to @blob.url(disposition: params[:disposition])
  end

  private

  def verify_blob_scan_status
    unless @blob.malware_scan_clean?
      redirect_to root_path, alert: "This file is not available for download."
    end
  end
end
