class PayScale < ApplicationRecord
  has_many :vacancies
  belongs_to :regional_pay_band_area

  default_scope { order(:index) }
  scope :current, (-> { where('expires_at >= ?', Time.zone.today).where('starts_at <= ?', Time.zone.today) })
end
