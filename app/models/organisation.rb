class Organisation < ApplicationRecord
  has_many :organisation_vacancies, dependent: :destroy
  has_many :vacancies, through: :organisation_vacancies

  scope :not_closed, -> { where.not(establishment_status: "Closed") }
  scope :schools, -> { where(type: "School") }
  scope :school_groups, -> { where(type: "SchoolGroup") }
  scope :trusts, -> { school_groups.where.not(uid: nil) }
  scope :local_authorities, -> { school_groups.where.not(local_authority_code: nil) }

  alias_attribute :data, :gias_data

  JOB_SORTING_OPTIONS = [
    ["Date to be published (Soonest)", "publish_on"],
    ["Closing date (Soonest)", "expires_on"],
    ["Job title (A to Z)", "job_title"],
    ["Location (A to Z)", "readable_job_location"],
  ].freeze

  def all_vacancies
    ids = is_a?(School) ? [id] : [id] + schools.pluck(:id)
    Vacancy.in_organisation_ids(ids)
  end
end
