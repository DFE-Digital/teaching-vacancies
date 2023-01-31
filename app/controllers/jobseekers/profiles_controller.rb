class Jobseekers::ProfilesController < Jobseekers::BaseController
  helper_method :form, :jobseeker_profile

  before_action :jobseeker_profile

  SECTIONS = [
    {
      title: "Personal details",
      condition: -> { current_jobseeker.jobseeker_profile.personal_details&.completed_steps.present? },
      link_text: "Add personal details",
      page_path: -> { personal_details_jobseekers_profile_path },
      partial: "jobseekers/profiles/personal_details/summary",
    },
    {
      title: "Job preferences",
      link_text: "Add job preferences",
      page_path: -> { "" },
    },
    {
      title: "Qualified teaching status (QTS)",
      link_text: "Add qualified teaching status",
      page_path: -> { "" },
    },
    {
      title: "Qualifications",
      link_text: "Add qualifications",
      page_path: -> { "" },
    },
    {
      title: "Work history",
      link_text: "Add roles",
      page_path: -> { "" },
    },
    {
      title: "About you",
      link_text: "Add details about you",
      page_path: -> { "" },
    },
    {
      title: "Hide profile from schools or trusts",
      link_text: "Set up who cannot view your profile",
      page_path: -> { "" },
    },
    {
      title: "Preview and turn on profile",
      link_text: "Preview profile",
      page_path: -> { "" },
    },
  ].map(&:freeze).freeze

  def show
    @sections = SECTIONS
  end

  private

  def jobseeker_profile
    @jobseeker_profile ||= JobseekerProfile.find_or_create_by(jobseeker_id: current_jobseeker.id)
  end
end
