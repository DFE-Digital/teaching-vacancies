require "digest"

class Organisation < ApplicationRecord
  has_many :organisation_vacancies, dependent: :destroy
  has_many :vacancies, through: :organisation_vacancies

  has_many :organisation_publishers, dependent: :destroy
  has_many :publishers, through: :organisation_publishers

  scope :not_closed, -> { where.not(establishment_status: "Closed") }
  scope :schools, -> { where(type: "School") }
  scope :school_groups, -> { where(type: "SchoolGroup") }
  scope :trusts, -> { school_groups.where.not(uid: nil) }
  scope :local_authorities, -> { school_groups.where.not(local_authority_code: nil) }

  alias_attribute :data, :gias_data

  def all_vacancies
    ids = school? ? [id] : [id] + schools.pluck(:id) + schools_outside_local_authority.pluck(:id)
    Vacancy.in_organisation_ids(ids)
  end

  def name
    @name ||= read_attribute(:name)&.concat(local_authority? ? " local authority" : "")
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

  # We bulk import organisations from GIAS, so cannot use ActiveRecord callbacks or rely on
  # the `updated_at` field to trigger "entity updated" events for our data warehouse.
  # Instead, we use a job to iterate over all organisations and call this method to recompute
  # the `gias_data_hash` and update it if it has changed, which will trigger an update event.
  def refresh_gias_data_hash
    computed_hash = gias_data.presence && Digest::SHA256.hexdigest(gias_data.to_s)
    return if gias_data_hash == computed_hash

    update(gias_data_hash: computed_hash)
  end
end
