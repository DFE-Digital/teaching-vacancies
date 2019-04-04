class Subscription < ApplicationRecord
  include Auditor::Model

  enum frequency: %i[daily]

  has_many :alert_runs

  validates :email, email_address: { presence: true }
  validates :reference, presence: true
  validates :frequency, presence: true
  validates :search_criteria, uniqueness: { scope: %i[email expires_on frequency] }

  scope :ongoing, -> { where('expires_on >= current_date') }

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
    parsed_criteria = (JSON.parse(search_criteria) if search_criteria.present?)
    @search_criteria_hash = if parsed_criteria.is_a?(Hash)
                              parsed_criteria
                            else
                              {}
                            end
  rescue JSON::ParserError
    @search_criteria_hash = {}
  end

  def token(expiration_in_days: 2)
    expires = Time.current + expiration_in_days.days
    token_values = { id: id, expires: expires }
    self.class.encryptor.encrypt_and_sign(token_values)
  end

  def vacancies_for_range(date_from, date_to)
    AlertResultFinder.new(search_criteria_to_h, date_from, date_to).call.records
  end

  def alert_run_today
    alert_runs.find_by(run_on: Time.zone.today)
  end

  def alert_run_today?
    alert_run_today.present?
  end

  def create_alert_run
    alert_runs.find_or_create_by(run_on: Time.zone.today)
  end

  def expired?
    expires_on < Time.zone.today
  end
end
