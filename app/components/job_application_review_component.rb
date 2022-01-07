class JobApplicationReviewComponent < ReviewComponent
  renders_many(:sections, lambda do |section_name, **kwargs|
    JobApplicationReviewComponent::Section.new(
      @job_application,
      name: section_name,
      **kwargs,
    )
  end)

  def initialize(job_application, step_process:, classes: [], html_attributes: {}, **kwargs)
    super(
      classes: classes,
      html_attributes: html_attributes,
      namespace: "jobseekers/job_applications",
      **kwargs,
    )

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
