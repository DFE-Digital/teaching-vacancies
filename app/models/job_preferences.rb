class JobPreferences < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile
  has_many :locations, dependent: :destroy

  def all_roles
    roles.map(&:humanize).join(", ")
  end

  def all_key_stages
    key_stages.map(&:humanize).join(", ")
  end

  def all_working_patterns
    working_patterns.map(&:humanize).join(", ")
  end
end
