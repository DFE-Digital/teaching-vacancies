require "zip"

class JobApplicationZipBuilder
  def initialize(vacancy:, job_applications:)
    @vacancy = vacancy
    @job_applications = job_applications
  end

  def generate
    Zip::OutputStream.write_buffer { |zio|
      @job_applications.each do |job_application|
        filename = job_application.name.tr(" ", "_")
        if @vacancy.uploaded_form?
          next unless job_application.application_form.attached?

          blob = job_application.application_form.blob
          extension = File.extname(blob.filename.to_s)

          zio.put_next_entry("#{filename}#{extension}")
          zio.write blob.download
        else
          presenter = JobApplicationPdf.new(job_application)
          zio.put_next_entry "#{filename}.pdf"
          zio.write JobApplicationPdfGenerator.new(presenter).generate.render
        end
      end
    }.tap(&:rewind)
  end
end
