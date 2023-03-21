class JobPreferences < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile
  has_many :locations, dependent: :destroy

  def vacancies(scope = Vacancy.live)
    JobScope.new(scope, self).call
  end

  def all_roles
    roles.join(", ")
  end

  def all_key_stages
    key_stages.join(", ")
  end

  def all_working_patterns
    working_patterns.join(", ")
  end
end
