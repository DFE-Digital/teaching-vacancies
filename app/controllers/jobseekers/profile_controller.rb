class Jobseekers::ProfileController < Jobseekers::BaseController
  SECTIONS = [
    {
      title: "Personal details",
      link_text: "Add personal details",
      page_path: -> { "" },
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
  ].freeze

  def index
    @sections = SECTIONS
  end
end
