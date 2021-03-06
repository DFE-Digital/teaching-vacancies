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
    ids = is_a?(School) ? [id] : [id] + schools.pluck(:id) + schools_outside_local_authority.pluck(:id)
    Vacancy.in_organisation_ids(ids)
  end

  def name
    @name ||= read_attribute(:name)&.concat(group_type == "local_authority" ? " local authority" : "")
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
end
