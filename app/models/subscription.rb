class Subscription < ApplicationRecord
  enum :frequency, { daily: 0, weekly: 1 }

  has_many :alert_runs, dependent: :destroy
  has_many :feedbacks, dependent: :destroy, inverse_of: :subscription

  scope :active, -> { where(active: true) }

  validates :email, email_address: true, if: -> { email_changed? } # Allows data created prior to validation to still be valid

  FILTERS = {
    teaching_job_roles: ->(vacancy, value) { vacancy.job_roles.intersect?(value) },
    support_job_roles: ->(vacancy, value) { vacancy.job_roles.intersect?(value) },
    # support_job_roles used to be called both of these in the past, and there are still active subscriptions with this name
    teaching_support_job_roles: ->(vacancy, value) { vacancy.job_roles.intersect?(value) },
    non_teaching_support_job_roles: ->(vacancy, value) { vacancy.job_roles.intersect?(value) },

    visa_sponsorship_availability: ->(vacancy, value) { value.include? vacancy.visa_sponsorship_available.to_s },
    ect_statuses: ->(vacancy, value) { value.include?(vacancy.ect_status) },
    #  legacy criteria ->  value always 'true'
    newly_qualified_teacher: ->(vacancy, value) { value == "true" && vacancy.ect_status.to_s == "ect_suitable" },
    subjects: ->(vacancy, value) { (vacancy.subjects || []).intersect?(value) },
    # legacy 'subject' criteria appears to be 1 single value
    subject: ->(vacancy, value) { (vacancy.subjects || []).include?(value) },
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

  def create_alert_run
    alert_runs.find_or_create_by(run_on: Date.current)
  end

  def organisation
    Organisation.find_by(slug: search_criteria["organisation_slug"]) if search_criteria["organisation_slug"]
  end

  def vacancies_matching(default_scope)
    scope = default_scope
    # ignore legacy sorting criteria - legacy job_title is too specific and will typically filter everything
    criteria = search_criteria.symbolize_keys.except(:jobs_sort, :job_title)
    scope, criteria = self.class.handle_location(scope, criteria)

    scope.select do |vacancy|
      criteria.all? { |criterion, value| FILTERS.fetch(criterion).call(vacancy, value) }
    end
  end

  extend DistanceHelper

  # These polygons seem to be extremely invalid - they respond to the 'invalid_reason' call by throwing an exception,
  # as opposed to the other 31 invalid ones in the production database, which are just 'invalid'
  INVALID_POLYGONS = ["somerset, bath and bristol",
                      "devon, plymouth and torbay",
                      "essex, southend and thurrock",
                      "leicestershire and rutland",
                      "lincolnshire and lincoln",
                      "derbyshire and derby"].freeze

  class << self
    def limit_by_location(vacancies, location, radius_in_miles)
      polygon = LocationPolygon.buffered(radius_in_miles).with_name(location)
      if polygon.present? && !polygon.name.in?(INVALID_POLYGONS) && polygon.area.invalid_reason.nil?
        vacancies.select { |v| v.organisations.map(&:geopoint).any? { |point| polygon.area.contains?(point) } }
      else
        radius_in_metres = convert_miles_to_metres radius_in_miles
        coordinates = Geocoding.new(location).coordinates
        search_point = RGeo::Geographic.spherical_factory(srid: 4326).point(coordinates.second, coordinates.first)
        vacancies.select { |v| v.organisations.map(&:geopoint).any? { |point| search_point.distance(point) < radius_in_metres } }
      end
    end

    def handle_location(scope, criteria)
      if criteria.key?(:location)
        location = criteria[:location].strip.downcase
        if location.blank? || LocationQuery::NATIONWIDE_LOCATIONS.include?(location)
          [scope, criteria.except(:location, :radius)]
        else
          [limit_by_location(scope, location, criteria[:radius] || 10), criteria.except(:location, :radius)]
        end
      else
        # ignore 'radius' keys that don't have a 'location' key
        [scope, criteria.except(:radius)]
      end
    end
  end
end
