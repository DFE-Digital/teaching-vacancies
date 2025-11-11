# frozen_string_literal: true

module JobApplicationsPdfHelper
  Document = Data.define(:filename, :data)

  def submitted_application_form(job_application)
    if job_application.vacancy.uploaded_form?
      if job_application.application_form.attached?
        extension = File.extname(job_application.application_form.filename.to_s)
        Document["application_form#{extension}", job_application.application_form.download]
      else
        Document["no_application_form.txt", "the candidate has no application for on record"]
      end
    else
      presenter = JobApplicationPdf.new(job_application)
      pdf = JobApplicationPdfGenerator.new(presenter).generate
      Document["application_form.pdf", pdf.render]
    end
  end
end
