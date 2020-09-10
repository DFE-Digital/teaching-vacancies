class SchoolGroup < Organisation
  has_many :school_group_memberships
  has_many :schools, through: :school_group_memberships

  # TODO: This should ideally be a stored as column in the database table
  def name
    gias_data['Group Name']&.titlecase
  end

  def group_type
    gias_data['Group Type']
  end

  def address
    gias_data['Group Locality']
  end

  def town
    gias_data['Group Town']
  end

  def county
    gias_data['Group County']
  end

  def postcode
    gias_data['Group Postcode']
  end
end
