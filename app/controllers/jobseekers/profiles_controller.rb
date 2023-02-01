class Jobseekers::ProfilesController < Jobseekers::BaseController
  SECTIONS = [
    {
      title: "Personal details",
      key: "",
      link_text: "Add personal details",
      page_path: -> { "" },
    },
    {
      title: "Job preferences",
      key: "",
      link_text: "Add job preferences",
      page_path: -> { "" },
    },
    {
      title: "Qualified teaching status (QTS)",
      key: "",
      link_text: "Add qualified teaching status",
      page_path: -> { "" },
    },
    {
      title: "Qualifications",
      key: "",
      link_text: "Add qualifications",
      page_path: -> { "" },
    },
    {
      title: "Work history",
      key: "",
      link_text: "Add roles",
      page_path: -> { "" },
    },
    {
      title: "About you",
      key: "about_you",
      link_text: "Add details about you",
      page_path: -> { edit_jobseekers_profile_about_you_path },
    },
    {
      title: "Hide profile from schools or trusts",
      key: "",
      link_text: "Set up who cannot view your profile",
      page_path: -> { "" },
    },
    {
      title: "Preview and turn on profile",
      key: "",
      link_text: "Preview profile",
      page_path: -> { "" },
    },
  ].map(&:freeze).freeze

  def show
    @profile = JobseekerProfile.where(jobseeker_id: current_jobseeker.id).first_or_create
    @sections = SECTIONS
  end
end
