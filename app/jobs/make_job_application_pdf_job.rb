class MakeJobApplicationPdfJob < ApplicationJob
  queue_as :low

  def perform(job_application)
    pdf = JobApplicationPdfGenerator.new(job_application, job_application.vacancy).generate
    pdf_data = pdf.render

    job_application.pdf_version.attach(io: StringIO.open(pdf_data),
                                       filename: "job_application_#{job_application.id}.pdf",
                                       identify: false,
                                       content_type: "application/pdf")
  end
end
