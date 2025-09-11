class VacancyAnalytics < ApplicationRecord
  belongs_to :vacancy
  validates :vacancy_id, uniqueness: true

  PRODUCTION_SERVICE_NAME = "teaching-vacancies.service.gov.uk".freeze

  def tidy_stats
    stats = referrer_counts.except("direct", PRODUCTION_SERVICE_NAME)
    stats = stats.merge({ "direct" => referrer_counts.fetch(PRODUCTION_SERVICE_NAME) }) if referrer_counts.key? PRODUCTION_SERVICE_NAME
    assign_attributes(referrer_counts: stats)
  end
end
