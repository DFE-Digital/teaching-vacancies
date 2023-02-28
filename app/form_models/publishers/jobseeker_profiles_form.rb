class Publishers::JobseekerProfilesForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :preferred_role
  attribute :qualified_teacher_status

  def preferred_role_options
    Vacancy.job_roles.keys.map { |i| [i, I18n.t(i, scope: "publishers.jobseeker_profiles.filters.preferred_role_options")] }
  end

  def qts_options
    %w[none on_track older_than_two older_than_three].map { |i| [i, I18n.t(i, scope: "publishers.jobseeker_profiles.filters.qts_options")] }
  end
end
