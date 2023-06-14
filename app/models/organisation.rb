require "digest"

class Organisation < ApplicationRecord
  before_save :update_searchable_content

  include PgSearch::Model
  extend FriendlyId

  SPECIAL_SCHOOL_TYPES = ["Community special school", "Foundation special school", "Non-maintained special school", "Academy special converter", "Academy special sponsor led", "Free schools special"].freeze
  NON_FAITH_RELIGIOUS_CHARACTER_TYPES = ["", "None", "Does not apply", "null"].freeze

  friendly_id :slug_candidates, use: :slugged

  has_one_attached :logo, service: :amazon_s3_images_and_logos
  has_one_attached :photo, service: :amazon_s3_images_and_logos

  has_many :organisation_vacancies, dependent: :destroy
  has_many :vacancies, through: :organisation_vacancies

  has_many :organisation_publishers, dependent: :destroy
  has_many :publishers, through: :organisation_publishers

  has_many :jobseeker_profile_exclusions, class_name: "JobseekerProfileExcludedOrganisation"
  has_many :hidden_jobseeker_profiles, through: :jobseeker_profile_exclusions, source: :jobseeker_profile

  scope :not_closed, -> { where.not(establishment_status: "Closed") }
  scope :schools, -> { where(type: "School") }
  scope :school_groups, -> { where(type: "SchoolGroup") }
  scope :trusts, -> { school_groups.where.not(uid: nil) }
  scope :local_authorities, -> { school_groups.where.not(local_authority_code: nil) }
  scope :within_polygon, ->(location_polygon) { where("ST_Intersects(?, geopoint)", location_polygon.area.to_s) if location_polygon }
  scope :within_area, lambda { |coordinates, radius|
    point = "POINT(#{coordinates&.second} #{coordinates&.first})"
    where("ST_DWithin(geopoint, ?, ?)", point, radius) if coordinates && radius
  }
  scope :in_vacancy_ids, (->(ids) { joins(:organisation_vacancies).where(organisation_vacancies: { vacancy_id: ids }).distinct })

  scope :search_by_location, OrganisationLocationQuery
  pg_search_scope :search_by_name,
                  against: :name,
                  using: { tsearch: { prefix: true, tsvector_column: "searchable_content" } }

  scope(:registered_for_service, lambda do
    registered_organisations = OrganisationPublisher.select(:organisation_id)
    where(id: registered_organisations)
      .or(where(id: SchoolGroupMembership.select(:school_id).where(school_group_id: registered_organisations)))
  end)

  scope :visible_to_jobseekers, -> { schools.not_closed.or(Organisation.trusts).registered_for_service }

  alias_attribute :data, :gias_data

  enum phase: {
    not_applicable: 0,
    nursery: 1,
    primary: 2,
    middle_deemed_primary: 3,
    secondary: 4,
    middle_deemed_secondary: 5,
    sixth_form_or_college: 6,
    through: 7,
  }

  def all_vacancies
    ids = school? ? [id] : [id] + schools.pluck(:id) + schools_outside_local_authority.pluck(:id)
    Vacancy.in_organisation_ids(ids)
  end

  def name
    local_authority? ? "#{read_attribute(:name)} local authority" : read_attribute(:name)
  end

  def url
    url_override.presence || super
  end

  def schools_outside_local_authority
    school_urns = Rails.configuration.local_authorities_extra_schools&.dig(local_authority_code.to_i)
    School.where(urn: school_urns)
  end

  def school?
    is_a?(School)
  end

  def school_group?
    is_a?(SchoolGroup)
  end

  def trust?
    uid.present?
  end

  def local_authority?
    local_authority_code.present?
  end

  def trust_or_la?
    trust? || local_authority?
  end

  # We bulk import organisations from GIAS, so cannot use ActiveRecord callbacks or rely on
  # the `updated_at` field to trigger "entity updated" events for our data warehouse.
  # Instead, we use a job to iterate over all organisations and call this method to recompute
  # the `gias_data_hash` and update it if it has changed, which will trigger an update event.
  def refresh_gias_data_hash
    computed_hash = gias_data.presence && Digest::SHA256.hexdigest(gias_data.to_s)
    return if gias_data_hash == computed_hash

    update(gias_data_hash: computed_hash)
  end

  def has_ofsted_report?
    urn.present?
  end

  def profile_complete?
    %i[email description safeguarding_information logo photo url].all? { |attribute| send(attribute).present? }
  end

  def self.update_all_searchable_content!
    Organisation.all.find_each do |organisation|
      organisation.update_columns(searchable_content: organisation.generate_searchable_content)
    end
  end

  def update_searchable_content
    self.searchable_content = generate_searchable_content
  end

  def generate_searchable_content
    Search::Postgres::TsvectorGenerator.new(
      a: [name],
    ).tsvector
  end

  private

  def slug_candidates
    [:name, %i[name town], %i[name postcode]]
  end
end
