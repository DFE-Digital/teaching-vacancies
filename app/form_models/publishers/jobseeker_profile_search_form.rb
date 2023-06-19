class Publishers::JobseekerProfileSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :current_organisation
  attribute :locations
  attribute :qualified_teacher_status
  attribute :roles
  attribute :working_patterns
  attribute :education_phases
  attribute :key_stages
  attribute :subjects
  attribute :right_to_work_in_uk

  ROLES = %w[teacher head_of_year_or_phase head_of_department_or_curriculum assistant_headteacher deputy_headteacher
             headteacher teaching_assistant higher_level_teaching_assistant education_support sendco].freeze

  def school_options
    current_organisation.schools.map { |school| [school.id, school.name] }
  end

  def role_options
    ROLES.map { |i| [i, I18n.t(i, scope: "publishers.jobseeker_profiles.filters.role_options")] }
  end

  def qts_options
    %w[yes on_track no].map { |i| [i, I18n.t(i, scope: "publishers.jobseeker_profiles.filters.qts_options")] }
  end

  def working_pattern_options
    %w[full_time part_time].map { |i| [i, I18n.t(i, scope: "publishers.jobseeker_profiles.filters.working_pattern_options")] }
  end

  def education_phase_options
    Vacancy.phases.keys.map { |i| [i, I18n.t(i, scope: "publishers.jobseeker_profiles.filters.education_phase_options")] }
  end

  def key_stage_options
    %w[early_years ks1 ks2 ks3 ks4 ks5].map { |i| [i, I18n.t(i, scope: "publishers.jobseeker_profiles.filters.key_stage_options")] }
  end

  def right_to_work_in_uk_options
    %w[true false].map { |i| [i, I18n.t(i, scope: "publishers.jobseeker_profiles.filters.right_to_work_in_uk_options")] }
  end
end
