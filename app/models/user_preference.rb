class UserPreference < ApplicationRecord
  belongs_to :user
  belongs_to :school_group, optional: true
end
