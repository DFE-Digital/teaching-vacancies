class JobApplicationReviewComponent < ApplicationComponent
  renders_one :header

  renders_one :above
  renders_one :below

  renders_one :sidebar, ReviewComponent::Sidebar

  renders_many(:sections, lambda do |section_name, **kwargs|
    case section_name
    when :catholic
      CatholicReligiousInformationSection.new(@job_application,
                                              name: section_name)
    when :non_catholic
      NonCatholicReligiousInformationSection.new(@job_application,
                                                 name: section_name)
    else
      Section.new(
        @job_application,
        name: section_name,
        **kwargs,
      )
    end
  end)

  attr_reader :job_application

  def initialize(job_application, show_sidebar: true, classes: [], html_attributes: {})
    super(
      classes: classes,
      html_attributes: html_attributes,
    )

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
