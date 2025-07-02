class JobApplicationZipBuilder
  def initialize(vacancy:, job_applications:)
    @vacancy = vacancy
    @job_applications = job_applications
  end

  def generate
    Zip::OutputStream.write_buffer do |zio|
      @job_applications.each do |job_application|
        if @vacancy.uploaded_form?
          next unless job_application.application_form.attached?

          zio.put_next_entry "#{job_application.first_name}_#{job_application.last_name}.pdf"
          zio.write job_application.application_form.download
        else
          zio.put_next_entry "#{job_application.first_name}_#{job_application.last_name}.pdf"
          zio.write JobApplicationPdfGenerator.new(job_application).generate.render
        end
      end
    end
  end
end
