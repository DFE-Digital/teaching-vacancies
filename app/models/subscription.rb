class Subscription < ApplicationRecord
  MAXIMUM_RESULTS_PER_RUN = 500

  enum frequency: { daily: 0, weekly: 1 }

  has_many :alert_runs, dependent: :destroy
  has_many :feedbacks

  scope :active, (-> { where(active: true) })

  before_create :fix_wrong_email

  def self.encryptor
    key_generator_secret = SUBSCRIPTION_KEY_GENERATOR_SECRET
    key_generator_salt = SUBSCRIPTION_KEY_GENERATOR_SALT

    key_generator = ActiveSupport::KeyGenerator
      .new(key_generator_secret, hash_digest_class: SUBSCRIPTION_KEY_GENERATOR_DIGEST_CLASS)
      .generate_key(key_generator_salt, 32)

    ActiveSupport::MessageEncryptor.new(key_generator)
  end

  def self.find_and_verify_by_token(token)
    data = encryptor.decrypt_and_verify(token)
    find(data[:id])
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    raise ActiveRecord::RecordNotFound
  end

  def token
    token_values = { id: id }
    self.class.encryptor.encrypt_and_sign(token_values)
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

  def fix_wrong_email
    self.email = email.gsub(/\.con$/, ".com")
  end

  def organisation
    Organisation.find_by(slug: search_criteria["organisation_slug"]) if search_criteria["organisation_slug"]
  end
end
