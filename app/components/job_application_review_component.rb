class JobApplicationReviewComponent < ApplicationComponent
  renders_one :header

  renders_one :above
  renders_one :below

  renders_one :sidebar, ReviewComponent::Sidebar

  renders_many(:sections, lambda do |section_name, **kwargs|
    JobApplicationReviewComponent::Section.new(
      @job_application,
      allow_edit: @allow_edit,
      name: section_name,
      **kwargs,
    )
  end)

  attr_reader :job_application

  def initialize(job_application, show_sidebar: true, allow_edit: nil, classes: [], html_attributes: {})
    super(
      classes: classes,
      html_attributes: html_attributes,
    )

    @allow_edit = allow_edit
    @job_application = job_application
    @show_sidebar = show_sidebar
  end

  def column_class
    show_sidebar? ? %w[govuk-grid-column-two-thirds] : %w[govuk-grid-column-full]
  end

  def show_sidebar?
    !!@show_sidebar
  end
end
