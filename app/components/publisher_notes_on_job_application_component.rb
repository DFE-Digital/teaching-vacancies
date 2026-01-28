class PublisherNotesOnJobApplicationComponent < ApplicationComponent
  attr_reader :job_application, :vacancy, :note, :return_to_url

  def initialize(job_application:, vacancy:, note:,
                 return_to_url: nil)
    super()

    @job_application = job_application
    @vacancy = vacancy
    @note = note
    @return_to_url = return_to_url
  end

  private

  def default_classes
    %w[publisher-notes-on-job-application-component]
  end
end
