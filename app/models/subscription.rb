class Subscription < ApplicationRecord
  enum status: %i[active trashed]
  enum frequency: %i[daily]

  validates :email, email_address: { presence: true }
  validates :frequency, presence: true
  validates :search_criteria, uniqueness: { scope: %i[email expires_on frequency] }

  scope :ongoing, -> { active.where('expires_on >= current_date') }

  before_save :set_reference

  def self.encryptor
    key_generator_secret = SUBSCRIPTION_KEY_GENERATOR_SECRET
    key_generator_salt = SUBSCRIPTION_KEY_GENERATOR_SALT

    key_generator = ActiveSupport::KeyGenerator.new(key_generator_secret)
                                               .generate_key(key_generator_salt, 32)

    ActiveSupport::MessageEncryptor.new(key_generator)
  end

  def self.find_and_verify_by_token(token)
    data = encryptor.decrypt_and_verify(token)
    expires = data[:expires]

    raise ActiveRecord::RecordNotFound if Time.current > expires

    find(data[:id])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    raise ActiveRecord::RecordNotFound
  end

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

  def token(expiration_in_days: 2)
    expires = Time.current + expiration_in_days.days
    token_values = { id: id, expires: expires }
    self.class.encryptor.encrypt_and_sign(token_values)
  end
end
