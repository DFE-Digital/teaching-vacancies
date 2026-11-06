class JobPreferences < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile
  has_many :locations, dependent: :destroy

  validates :jobseeker_profile, uniqueness: true

  def vacancies(scope = PublishedVacancy.live)
    JobScope.new(scope, self).call
  end

  def all_working_patterns
    working_patterns.map(&:humanize).join(", ")
  end
end
