class PayScale < ApplicationRecord
  has_many :vacancies

  default_scope { order(:index) }
  scope :current, (-> { where('expires_at >= ?', Time.zone.today).where('starts_at <= ?', Time.zone.today) })

  def self.minimum_payscale_salary
    PayScale.minimum(:salary).to_i
  end
end
