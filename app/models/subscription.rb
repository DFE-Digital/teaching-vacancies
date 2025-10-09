# frozen_string_literal: true

class Subscription < ApplicationRecord
  enum :frequency, { daily: 0, weekly: 1 }

  has_many :alert_runs, dependent: :destroy
  # don't delete feedbacks when subscriptions are destroyed
  has_many :feedbacks, dependent: :nullify, inverse_of: :subscription

  # subscriptions are discarded in 2 places:
  # a) on account de-activation (in case we need to bring them back)
  # b) on removal (because we need to process feedback when removing)
  #   in this second case, the subscription will be destroyed by rake task the following day
  include Discard::Model

  self.discard_column = :unsubscribed_at

  validates :email, email_address: true, if: -> { email_changed? } # Allows data created prior to validation to still be valid

  FILTERS = {
    job_roles: ->(vacancy, value) { value.any? { |v| vacancy.job_roles.intersect?(v) } },

    visa_sponsorship_availability: ->(vacancy, value) { value.include? vacancy.visa_sponsorship_available.to_s },
    ect_statuses: ->(vacancy, value) { value.include?(vacancy.ect_status) },
    #  legacy criteria ->  value always 'true'
    newly_qualified_teacher: ->(vacancy, value) { value == "true" && vacancy.ect_status.to_s == "ect_suitable" },
    subjects: ->(vacancy, value) { (vacancy.subjects || []).intersect?(value) },
    # legacy 'subject' criteria appears to be 1 single value
    subject: ->(vacancy, value) { (vacancy.subjects || []).include?(value) },
    phases: ->(vacancy, value) { (vacancy.phases || []).intersect?(value) },
    working_patterns: ->(vacancy, value) { working_pattern_match?(vacancy, value) },
    organisation_slug: ->(vacancy, value) { vacancy.organisations.map(&:slug).include?(value) },
    keyword: ->(vacancy, value) { value.downcase.strip.split.all? { |k| vacancy.searchable_content.include? k } },
  }.freeze

  # support_job_roles used to be called teaching_support_job_roles and non_teaching_support_job_roles in the past, and there are still active subscriptions with this name
  JOB_ROLE_ALIASES = %i[teaching_job_roles support_job_roles teaching_support_job_roles non_teaching_support_job_roles].freeze

  # temp - can't delete a column until this change has been deployed as it would break running versions
  # during the deploy
  self.ignored_columns += %w[active]

  class << self
    def working_pattern_match?(vacancy, working_patterns)
      if working_patterns == %w[job_share]
        vacancy.is_job_share
      elsif working_patterns.include?("job_share")
        vacancy.is_job_share || vacancy.working_patterns.intersect?(working_patterns - %w[job_share])
      else
        vacancy.working_patterns.intersect?(working_patterns)
      end
    end
  end

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

  def alert_run_today
    alert_runs.find_by(run_on: Date.current)
  end

  def create_alert_run
    alert_runs.find_or_create_by(run_on: Date.current)
  end

  def organisation
    Organisation.find_by(slug: search_criteria["organisation_slug"]) if search_criteria["organisation_slug"]
  end

  def vacancies_matching(scope)
    # ignore legacy sorting criteria - legacy job_title is too specific and will typically filter everything
    criteria = search_criteria.symbolize_keys.except(:jobs_sort, :job_title, :minimum_salary)

    # as there is just 1 'job_roles' field in TV but multiple search criteria, treat them all as aliases of each other
    # and convert them into an array matcher using any?
    if JOB_ROLE_ALIASES.any? { |job_role_alias| criteria.key?(job_role_alias) }
      job_roles = criteria.slice(*JOB_ROLE_ALIASES).values
      criteria[:job_roles] = job_roles
    end

    filters = criteria.except(*JOB_ROLE_ALIASES, :location, :radius).map do |criterion, value|
      ->(vacancy) { FILTERS.fetch(criterion).call(vacancy, value) }
    end

    vacancies = scope.select do |vacancy|
      filters.all? { |f| f.call(vacancy) }
    end

    # Location handling is the most expensive operations, since they involve polygons or geocoding computations in DB.
    # So do it last, and only if there are any vacancies left to filter after the other criteria have been applied over
    # the in-memory vacancy set.
    if vacancies.any?
      self.class.handle_location(vacancies, criteria)
    else
      vacancies
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
                      "derbyshire and derby",
                      "county durham, darlington, hartlepool and stockton",
                      "cheshire",
                      "staffordshire and stoke",
                      "lancashire, blackburn and blackpool"].freeze

  class << self
    def limit_by_location(vacancies, location, radius_in_miles)
      polygon = LocationPolygon.buffered(radius_in_miles).with_name(location)
      begin
        if polygon.present? && !polygon.name.in?(INVALID_POLYGONS) && polygon.area.invalid_reason.nil?
          return vacancies.select { |v| v.organisations.map(&:geopoint).any? { |point| polygon.area.contains?(point) } }
        end
      rescue RGeo::Error::InvalidGeometry => e
        Sentry.with_scope do |scope|
          scope.set_context("Polygon", { id: polygon.id, name: polygon.name })
          Sentry.capture_exception(e)
        end
      end

      radius_in_metres = convert_miles_to_metres(radius_in_miles)
      coordinates = Geocoding.new(location).coordinates
      search_point = RGeo::Geographic.spherical_factory(srid: 4326).point(coordinates.second, coordinates.first)
      vacancies.select { |v| v.organisations.map(&:geopoint).any? { |point| search_point.distance(point) < radius_in_metres } }
    end

    def handle_location(vacancies, criteria)
      if criteria.key?(:location)
        location = criteria[:location].strip.downcase
        if location.blank? || LocationQuery::NATIONWIDE_LOCATIONS.include?(location)
          vacancies
        else
          limit_by_location(vacancies, location, criteria[:radius] || 10)
        end
      else
        vacancies
      end
    end
  end

  # Reads the location and radius from the search criteria and precomputes the area or geopoint for faster matching later.
  # Expensive operations (external API calls or database geometry operations).
  # Avoid calling this method directly on the user request path.
  def set_location_data!
    location = search_criteria["location"]&.strip&.downcase
    return if location.blank?

    radius = search_criteria["radius"] || 10

    if (polygon = LocationPolygon.find_valid_for_location(location))
      set_location_from_polygon(polygon, radius)
    elsif (coordinates = Geocoding.new(location).coordinates)
      set_location_from_coordinates(coordinates, radius) if coordinates != Geocoding::COORDINATES_NO_MATCH
    end
    save!
  end

  private

  # A subscription with location area has a polygon area seat buffered by radius, no geopoint.
  def set_location_from_polygon(polygon, radius)
    # Cast polygon area from geography to geometry and buffer by radius before storing
    self.area = polygon.buffered_geometry_area(self.class.convert_miles_to_metres(radius))
    self.geopoint = nil
    self.radius_in_metres = self.class.convert_miles_to_metres(radius)
  end

  # A subscription with location coordinates has a geopoint, no area.
  def set_location_from_coordinates(coordinates, radius)
    self.geopoint = RGeo::Cartesian.factory(srid: 4326).point(coordinates.second, coordinates.first)
    self.area = nil
    self.radius_in_metres = self.class.convert_miles_to_metres(radius)
  end
end
