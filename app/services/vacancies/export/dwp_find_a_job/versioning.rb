module Vacancies::Export::DwpFindAJob::Versioning
  # Find a Job vacancies can only be live to 30 days from the original posted date.
  # They need to ve reposted as a different job advert every 31 days.
  DAYS_BETWEEN_REPOSTS = 31
  MIN_LIVE_DAYS = 1
  MAX_LIVE_DAYS = 30

  # It generates a versioned reference for a vacancy.
  # The original reference for a vacancy on its first publishing period in Find a Job service is the vacancy id.
  # Each repost period will version the reference as "id-1", "id-2", "id-3", etc.
  def versioned_reference(vacancy)
    version = version(vacancy)
    return unless version

    version.zero? ? vacancy.id : vacancy.id + "-#{version}"
  end

  # Each repost of a vacancy will have an incremental version number.
  def version(vacancy)
    return if vacancy.publish_on.blank? || vacancy.publish_on.to_date > Date.today

    published_days = (Date.today - vacancy.publish_on.to_date).to_i
    if published_days < DAYS_BETWEEN_REPOSTS
      0
    else
      published_days / DAYS_BETWEEN_REPOSTS
    end
  end
end
