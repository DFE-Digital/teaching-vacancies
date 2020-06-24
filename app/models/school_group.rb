class SchoolGroup < ApplicationRecord
  has_many :school_group_memberships
  has_many :schools, through: :school_group_memberships
end
