class Publishers::JobseekerProfileSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :current_organisation
  attribute :locations
  attribute :qualified_teacher_status
  attribute :teaching_job_roles
  attribute :support_job_roles
  attribute :working_patterns
  attribute :education_phases
  attribute :key_stages
  attribute :subjects
  attribute :right_to_work_in_uk

  def school_options
    current_organisation.schools.map { |school| [school.id, school.name] }
  end

  def teaching_job_role_options
    Vacancy::TEACHING_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.teaching_job_role_options.#{option}")] }
  end

  def support_job_role_options
    Vacancy::SUPPORT_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.#{option}")] }
  end

  def qts_options
    %w[yes on_track no].map { |i| [i, I18n.t(i, scope: "publishers.jobseeker_profiles.filters.qts_options")] }
  end

  def working_pattern_options
    %w[full_time part_time flexible job_share term_time].map do |working_pattern|
      [working_pattern, I18n.t(working_pattern, scope: "publishers.jobseeker_profiles.filters.working_pattern_options")]
    end
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
