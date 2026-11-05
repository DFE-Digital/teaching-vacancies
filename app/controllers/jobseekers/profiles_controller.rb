class Jobseekers::ProfilesController < Jobseekers::BaseController
  include Jobseekers::QualificationFormConcerns

  before_action :set_profile

  helper_method :qualification_form_param_key

  SECTIONS = [
    {
      title: "Personal details",
      display_summary: ->(profile) { profile.personal_details.present? },
      key: "personal_details",
      link_text: "Add personal details",
      page_path: -> { edit_jobseekers_profile_personal_details_path },
    },
    {
      title: "Job preferences",
      display_summary: ->(profile) { profile.job_preferences&.completed_steps.present? },
      key: "job_preferences",
      link_text: "Add job preferences",
      page_path: -> { jobseekers_job_preferences_step_path(Wicked::FIRST_STEP) },
    },
    {
      title: "Professional status",
      display_summary: ->(profile) { profile.qualified_teacher_status.present? },
      key: "qualified_teacher_status",
      link_text: "Add qualified teacher status",
      page_path: -> { edit_jobseekers_profile_qualified_teacher_status_path },
    },
    {
      title: "Qualifications",
      display_summary: ->(profile) { profile.qualifications.present? },
      key: "qualifications",
      link_text: "Add qualifications",
      page_path: -> { select_category_jobseekers_profile_qualifications_path },
    },
    {
      title: "Work history",
      display_summary: ->(profile) { profile.employments.any? },
      key: "employments",
      link_text: "Add a job or voluntary role",
      page_path: -> { new_jobseekers_profile_work_history_path },
    },
    {
      title: "Your personal statement",
      display_summary: ->(profile) { profile.about_you.present? },
      key: "about_you",
      link_text: "Add details about you",
      page_path: -> { edit_jobseekers_profile_about_you_path },
      partial: "jobseekers/profiles/about_you/summary",
    },
  ].map(&:freeze).freeze

  def show
    @sections = SECTIONS
  end

  private

  def set_profile
    @profile = JobseekerProfile.prepare(jobseeker: current_jobseeker) do
      flash.now[:success] = t("jobseekers.profiles.show.imported")
    end
  end
end
