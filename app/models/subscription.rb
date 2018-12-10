class Subscription < ApplicationRecord
  enum status: %i[active trashed]
  enum frequency: %i[daily]

  validates :email, email_address: { presence: true }
  validates :frequency, presence: true
  validates :search_criteria, uniqueness: { scope: %i[email expires_on frequency] }

  scope :ongoing, -> { active.where('expires_on >= current_date') }

  before_create :set_reference

  def set_reference
    loop do
      self.reference ||= SecureRandom.hex(8)
      break unless self.class.exists?(email: email, reference: self.reference)
    end
  end
end
