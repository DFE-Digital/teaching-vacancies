class Publishers::JobseekerProfileSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :roles
  attribute :qualified_teacher_status
  attribute :working_patterns
  attribute :education_phases
  attribute :key_stages

  def role_options
    Vacancy.job_roles.keys.map { |i| [i, I18n.t(i, scope: "publishers.jobseeker_profiles.filters.role_options")] }
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
end
