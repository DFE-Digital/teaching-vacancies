class JobPreferences < ApplicationRecord
  include ProfileSection
  include KeyStagesChecks

  belongs_to :jobseeker_profile
  has_many :locations, dependent: :destroy

  validates :jobseeker_profile, uniqueness: true

  def vacancies(scope = PublishedVacancy.live)
    JobScope.new(scope, self).call
  end

  def all_working_patterns
    working_patterns.map(&:humanize).join(", ")
  end

  def all_subjects
    subjects.map(&:humanize).join(", ")
  end

  def complete?
    steps = completed_steps.symbolize_keys
    %i[roles phases key_stages subjects working_patterns locations].all? { |step| steps.include?(step) && steps[step].to_sym.in?(%i[completed skipped]) }
  end
end
