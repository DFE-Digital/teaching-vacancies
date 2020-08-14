class Organisation < ApplicationRecord
  has_many :organisation_vacancies, dependent: :destroy
  has_many :vacancies, through: :organisation_vacancies

  scope :schools, -> { where(type: 'School') }
  scope :school_groups, -> { where(type: 'SchoolGroup') }

  alias_attribute :data, :gias_data

  def all_vacancies
    ids = is_a?(School) ? [id] : [id] + schools.pluck(:id)
    Vacancy.in_organisation_ids(ids)
  end
end
