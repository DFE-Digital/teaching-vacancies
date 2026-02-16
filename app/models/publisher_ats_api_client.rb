class PublisherAtsApiClient < ApplicationRecord
  has_many :vacancies, dependent: :destroy
  has_many :vacancy_conflict_attempts, dependent: :destroy

  before_validation :generate_api_key, on: :create

  validates :name, presence: true
  validates :api_key, presence: true
  validates :last_rotated_at, presence: true

  def generate_api_key
    self.api_key ||= SecureRandom.hex(20)
    self.last_rotated_at ||= Time.current
  end

  def rotate_api_key!
    update!(api_key: SecureRandom.hex(20), last_rotated_at: Time.current)
  end

  def unique_organisations_count
    vacancies.joins(:organisations).distinct.count("organisations.id")
  end
end
