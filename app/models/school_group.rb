class SchoolGroup < ApplicationRecord
  has_many :school_group_memberships
  has_many :schools, through: :school_group_memberships

  has_many :vacancies

  # TODO: This should ideally be a stored as column in the database table
  def name
    gias_data['Group Name']&.titlecase
  end

  def group_type
    gias_data['Group Type']
  end

  def address
    gias_data['Group Contact Street']
  end

  def town
    gias_data['Group Contact Town']
  end

  def county
    gias_data['Group Contact County']
  end

  def postcode
    gias_data['Group Contact Postcode']
  end
end
