class Subscription < ApplicationRecord
  enum status: %i[active trashed]
  enum frequency: %i[daily]

  validates :email, email_address: { presence: true }
  validates :frequency, presence: true
  validates :search_criteria, uniqueness: { scope: %i[email expires_on frequency] }

  scope :ongoing, -> { active.where('expires_on >= current_date') }

  before_save :set_reference

  def search_criteria_to_h
    @search_criteria_hash = JSON.parse(search_criteria)
  end

  def set_reference
    return if reference.present?
    self.reference = loop do
      reference = SecureRandom.hex(8)
      break reference unless self.class.exists?(email: email, reference: reference)
    end
  end
end
