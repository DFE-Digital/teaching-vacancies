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

  def self.migrate_legacy_working_patterns
    where.not(working_patterns: nil).find_each do |jp|
      if jp.working_patterns.include?("term_time")
        jp.assign_attributes(working_patterns: (jp.working_patterns - %w[term_time] + %w[full_time]).uniq)
      end
      if jp.working_patterns.include?("flexible")
        jp.assign_attributes(working_patterns: (jp.working_patterns - %w[flexible] + %w[part_time]).uniq)
      end
      jp.save!(validate: false, touch: false)
    end
  end
end
