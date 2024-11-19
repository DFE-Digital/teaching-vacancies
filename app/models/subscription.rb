class Subscription < ApplicationRecord
  MAXIMUM_RESULTS_PER_RUN = 500

  enum :frequency, { daily: 0, weekly: 1 }

  has_many :alert_runs, dependent: :destroy
  has_many :feedbacks, dependent: :destroy, inverse_of: :subscription

  scope :active, -> { where(active: true) }

  validates :email, email_address: true, if: -> { email_changed? } # Allows data created prior to validation to still be valid

  def self.encryptor(serializer: :json_allow_marshal)
    key_generator_secret = SUBSCRIPTION_KEY_GENERATOR_SECRET
    key_generator_salt = SUBSCRIPTION_KEY_GENERATOR_SALT

    key_generator = ActiveSupport::KeyGenerator
      .new(key_generator_secret, hash_digest_class: SUBSCRIPTION_KEY_GENERATOR_DIGEST_CLASS)
      .generate_key(key_generator_salt, 32)

    ActiveSupport::MessageEncryptor.new(key_generator, serializer: serializer)
  end

  def self.find_and_verify_by_token(token)
    data = begin
             encryptor(serializer: :json_allow_marshal).decrypt_and_verify(token)
           rescue ActiveSupport::MessageEncryptor::InvalidMessage
             encryptor(serializer: :marshal).decrypt_and_verify(token)
           end
    find(data.symbolize_keys[:id])
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    raise ActiveRecord::RecordNotFound
  end

  def token
    token_values = { id: id }
    self.class.encryptor(serializer: :json_allow_marshal).encrypt_and_sign(token_values)
  end

  def unsubscribe
    update(email: nil, active: false, unsubscribed_at: Time.current)
  end

  def vacancies_for_range(date_from, date_to)
    criteria = search_criteria.symbolize_keys.merge(from_date: date_from, to_date: date_to)
    Search::VacancySearch.new(criteria).vacancies.limit(MAXIMUM_RESULTS_PER_RUN)
  end

  def alert_run_today
    alert_runs.find_by(run_on: Date.current)
  end

  def alert_run_today?
    alert_run_today.present?
  end

  def create_alert_run
    alert_runs.find_or_create_by(run_on: Date.current)
  end

  def organisation
    Organisation.find_by(slug: search_criteria["organisation_slug"]) if search_criteria["organisation_slug"]
  end
end
