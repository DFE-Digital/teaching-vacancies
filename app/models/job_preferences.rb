class JobPreferences < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile
  has_many :locations, dependent: :destroy

  validates :jobseeker_profile, uniqueness: true

  def vacancies(scope = Vacancy.live)
    JobScope.new(scope, self).call
  end

  def all_roles
    roles.map(&:humanize).join(", ")
  end

  def all_key_stages
    key_stages.map(&:humanize).join(", ")
  end

  def all_working_patterns
    working_patterns.map(&:humanize).join(", ")
  end

  def all_subjects
    subjects.map(&:humanize).join(", ")
  end

  def complete?
    to_multistep.completed?
  end

  def to_multistep
    Jobseekers::JobPreferencesForm.from_record(self)
  end

  def key_stages_for_phases
    phases.map { |phase| Vacancy::PHASES_TO_KEY_STAGES_MAPPINGS[phase.to_sym] }.flatten.uniq.sort
  end
end
