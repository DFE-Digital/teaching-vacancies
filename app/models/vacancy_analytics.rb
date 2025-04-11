class VacancyAnalytics < ApplicationRecord
  belongs_to :vacancy
  validates :vacancy_id, uniqueness: true
end
