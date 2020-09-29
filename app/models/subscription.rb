class Subscription < ApplicationRecord
  include Auditor::Model

  FREQUENCY_OPTIONS = {
    daily: 0,
    weekly: 1,
  }.freeze

  enum frequency: FREQUENCY_OPTIONS

  has_many :alert_runs

  validates :email, email_address: { presence: true }
  validates :frequency, presence: true
  validates :search_criteria, uniqueness: { scope: %i[email frequency] }

  after_initialize :default_reference

  def self.encryptor
    key_generator_secret = SUBSCRIPTION_KEY_GENERATOR_SECRET
    key_generator_salt = SUBSCRIPTION_KEY_GENERATOR_SALT

    key_generator = ActiveSupport::KeyGenerator.new(key_generator_secret)
                                               .generate_key(key_generator_salt, 32)

    ActiveSupport::MessageEncryptor.new(key_generator)
  end

  def self.find_and_verify_by_token(token)
    data = encryptor.decrypt_and_verify(token)
    find(data[:id])
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    raise ActiveRecord::RecordNotFound
  end

  def search_criteria_to_h
    parsed_criteria = JSON.parse(search_criteria) if search_criteria.present?
    parsed_criteria.is_a?(Hash) ? parsed_criteria : {}
  rescue JSON::ParserError
    {}
  end

  def token
    token_values = { id: id }
    self.class.encryptor.encrypt_and_sign(token_values)
  end

  def vacancies_for_range(date_from, date_to)
    Algolia::VacancyAlertBuilder.new(
      search_criteria_to_h.symbolize_keys.merge(from_date: date_from, to_date: date_to),
    ).call
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

private

  def default_reference
    self.reference = SubscriptionReferenceGenerator.new(search_criteria: search_criteria_to_h).generate
  end
end
