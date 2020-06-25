class SchoolGroupMembership < ApplicationRecord
  belongs_to :school
  belongs_to :school_group
end
