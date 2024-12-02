class JobApplicationReviewComponent < ReviewComponent
  renders_many(:sections, lambda do |section_name, **kwargs|
    JobApplicationReviewComponent::Section.new(
      @job_application,
      allow_edit: @allow_edit,
      name: section_name,
      **kwargs,
    )
  end)

  attr_reader :job_application

  def initialize(job_application, step_process:, allow_edit: nil, classes: [], html_attributes: {}, **)
    super(
      classes: classes,
      html_attributes: html_attributes,
      namespace: "jobseekers/job_applications",
      **,
    )

    @allow_edit = allow_edit
    @job_application = job_application
    @step_process = step_process
  end

  private

  def track_assigns
    super.merge(
      job_application: @job_application,
      step_process: @step_process,
    )
  end
end
