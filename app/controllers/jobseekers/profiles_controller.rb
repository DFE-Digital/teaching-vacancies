class Jobseekers::ProfilesController < Jobseekers::BaseController
  before_action :profile, only: %i[show]

  SECTIONS = [
    {
      title: "Personal details",
      display_summary: -> { current_jobseeker.jobseeker_profile.personal_details&.completed_steps.present? },
      key: "personal_details",
      link_text: "Add personal details",
      page_path: -> { personal_details_jobseekers_profile_path },
    },
    {
      title: "Job preferences",
      display_summary: -> { current_jobseeker.job_preferences&.completed_steps.present? },
      key: "job_preferences",
      link_text: "Add job preferences",
      page_path: -> { jobseekers_job_preferences_path },
    },
    {
      title: "Qualified teacher status (QTS)",
      display_summary: -> { false },
      key: "qualified_teacher_status",
      link_text: "Add qualified teacher status",
      page_path: -> { edit_jobseekers_profile_qualified_teacher_status_path },
    },
    {
      title: "Qualifications",
      display_summary: -> { false },
      key: "",
      link_text: "Add qualifications",
      page_path: -> { "" },
    },
    {
      title: "Work history",
      display_summary: -> { false },
      key: "",
      link_text: "Add roles",
      page_path: -> { "" },
    },
    {
      title: "About you",
      display_summary: -> { @profile.about_you.present? },
      key: "about_you",
      condition: -> { current_jobseeker.jobseeker_profile.about_you.present? },
      link_text: "Add details about you",
      page_path: -> { edit_jobseekers_profile_about_you_path },
      partial: "jobseekers/profiles/about_you/summary",
    },
    {
      title: "Hide profile from schools or trusts",
      display_summary: -> { false },
      key: "",
      link_text: "Set up who cannot view your profile",
      page_path: -> { "" },
    },
    {
      title: "Preview and turn on profile",
      display_summary: -> { false },
      key: "",
      link_text: "Preview profile",
      page_path: -> { "" },
    },
  ].map(&:freeze).freeze

  def show
    @sections = SECTIONS
  end

  private

  def profile
    @profile ||= JobseekerProfile.find_or_create_by(jobseeker_id: current_jobseeker.id)
  end
end
