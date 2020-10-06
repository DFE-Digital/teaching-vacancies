class SchoolGroup < Organisation
  has_many :school_group_memberships
  has_many :schools, through: :school_group_memberships

  # TODO: This should ideally be a stored as column in the database table
  def group_type
    gias_data['Group Type']
  end
end
