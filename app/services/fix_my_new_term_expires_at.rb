class FixMyNewTermExpiresAt
  # BST 2026: starts 2026-03-29 01:00 UTC, ends 2026-10-25 01:00 UTC
  # MyNewTerm sent expires_at as "local BST time stored as if it were UTC".
  # The bug was fixed at 10:56 BST on 21 April 2026 (= 09:56 UTC).
  # Vacancies created before that cutoff (regardless of when they were created)
  # may have a BST expiry that needs correcting.
  VACANCY_CREATED_UNTIL = Time.utc(2026, 4, 21, 9, 56, 0).freeze

  # Only fix vacancies whose expires_at falls inside the BST window.
  # Vacancies expiring after BST ends would be in GMT, where no offset error applies.
  EXPIRES_AT_UNTIL = Time.utc(2026, 10, 25, 1, 0, 0).freeze

  ATS_CLIENT_NAME = "MyNewTerm".freeze

  def self.call
    new.call
  end

  def call
    client = PublisherAtsApiClient.find_by!(name: ATS_CLIENT_NAME)

    vacancies = client.vacancies
      .where(created_at: ...VACANCY_CREATED_UNTIL)
      .where(expires_at: Time.current..EXPIRES_AT_UNTIL)

    count = 0
    vacancies.find_each do |vacancy|
      vacancy.update_columns(expires_at: vacancy.expires_at - 1.hour)
      count += 1
    end

    Rails.logger.info("FixMyNewTermExpiresAt: fixed #{count} vacancies")
    count
  end
end
