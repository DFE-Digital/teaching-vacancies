class Subscription < ApplicationRecord
  enum :frequency, { daily: 0, weekly: 1 }

  has_many :alert_runs, dependent: :destroy
  has_many :feedbacks, dependent: :destroy, inverse_of: :subscription

  scope :active, -> { where(active: true) }

  validates :email, email_address: true, if: -> { email_changed? } # Allows data created prior to validation to still be valid

  FILTERS = {
    teaching_job_roles: ->(vacancy, value) { vacancy.job_roles.intersect?(value) },
    support_job_roles: ->(vacancy, value) { vacancy.job_roles.intersect?(value) },
    visa_sponsorship_availability: ->(vacancy, value) { value.include? vacancy.visa_sponsorship_available.to_s },
    ect_statuses: ->(vacancy, value) { value.include?(vacancy.ect_status) },
    subjects: ->(vacancy, value) { vacancy.subjects.intersect?(value) },
    phases: ->(vacancy, value) { vacancy.phases.intersect?(value) },
    working_patterns: ->(vacancy, value) { vacancy.working_patterns.intersect?(value) },
    organisation_slug: ->(vacancy, value) { vacancy.organisations.map(&:slug).include?(value) },
    keyword: ->(vacancy, value) { vacancy.searchable_content.include? value.downcase.strip },
  }.freeze

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

  def vacancies_matching(default_scope)
    scope = default_scope
    criteria = search_criteria.symbolize_keys
    scope, criteria = handle_location(scope, criteria)

    scope.select do |vacancy|
      criteria.all? { |criterion, value| FILTERS.fetch(criterion).call(vacancy, value) }
    end
  end

  private

  extend DistanceHelper

  class << self
    def limit_by_location(vacancies, location, radius_in_miles)
      query = location.strip.downcase
      if query.blank? || LocationQuery::NATIONWIDE_LOCATIONS.include?(query)
        vacancies
      else
        polygon = LocationPolygon.buffered(radius_in_miles).with_name(query)
        if polygon.present?
          vacancies.select { |v| v.organisations.map(&:geopoint).any? { |point| polygon.area.contains?(point) } }
        else
          radius_in_metres = convert_miles_to_metres radius_in_miles
          coordinates = Geocoding.new(query).coordinates
          search_point = RGeo::Geographic.spherical_factory.point(coordinates.second, coordinates.first)
          vacancies.select { |v| v.organisations.map(&:geopoint).any? { |point| search_point.distance(point) < radius_in_metres } }
        end
      end
    end
  end

  def handle_location(scope, criteria)
    if criteria.key?(:location)
      [self.class.limit_by_location(scope, criteria[:location], criteria[:radius]), criteria.except(:location, :radius)]

    else
      [scope, criteria]
    end
  end
end
