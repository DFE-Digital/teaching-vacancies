class JobPreferences < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile
  has_many :locations, dependent: :destroy

  def all_roles
    roles.join(", ")
  end

  def all_key_stages
    key_stages.join(", ")
  end

  def all_working_patterns
    key_stages.join(", ")
  end
end
