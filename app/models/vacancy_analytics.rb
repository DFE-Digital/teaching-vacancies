class VacancyAnalytics < ApplicationRecord
  belongs_to :vacancy

  def self.increment_view(vacancy_id, referrer)
    record = find_or_create_by!(vacancy_id: vacancy_id)

    record.increment!(:view_count)

    referrers = record.referrer_counts || {}
    referrer_key = referrer.present? ? URI(referrer).host : "direct"
    referrers[referrer_key] = referrers.fetch(referrer_key, 0) + 1

    record.update!(referrer_counts: referrers)
  end
end
