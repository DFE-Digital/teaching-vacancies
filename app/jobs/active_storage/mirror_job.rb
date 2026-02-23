class ActiveStorage::MirrorJob < ActiveStorage::BaseJob
  queue_as { ActiveStorage.queues[:mirror] }

  discard_on ActiveStorage::FileNotFoundError
  retry_on ActiveStorage::IntegrityError, attempts: 10, wait: :polynomially_longer

  # Override to fix Rails bug where MirrorJob always uses the default service
  # instead of the blob's actual service. This causes mirroring to fail for
  # attachments using non-default ActiveStorage services (e.g., images_and_logos).
  #
  # See: https://github.com/rails/rails/issues/46806
  # Proposed fix: https://github.com/Sandgarden-Demo/rails/pull/31/changes
  def perform(key, checksum:)
    if (blob = ActiveStorage::Blob.find_by(key: key))
      blob.service.try(:mirror, blob.key, checksum: blob.checksum)
    else
      ActiveStorage::Blob.service.try(:mirror, key, checksum: checksum)
    end
  end
end
