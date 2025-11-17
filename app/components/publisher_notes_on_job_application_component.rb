class PublisherNotesOnJobApplicationComponent < ApplicationComponent
  attr_reader :job_application, :vacancy, :notes_form, :return_to_url, :notes_url

  def initialize(job_application:, vacancy:, notes_form:, notes_url:,
                 return_to_url: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @job_application = job_application
    @vacancy = vacancy
    @notes_form = notes_form
    @return_to_url = return_to_url
    @notes_url = notes_url
  end

  private

  def default_classes
    %w[publisher-notes-on-job-application-component]
  end
end
