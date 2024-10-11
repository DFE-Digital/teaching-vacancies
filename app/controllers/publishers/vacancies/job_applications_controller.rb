class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  include DatesHelper

  include ActionController::Live

  helper_method :employments, :form, :job_applications, :qualification_form_param_key, :sort, :sorted_job_applications

  def reject
    raise ActionController::RoutingError, "Cannot reject a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?
  end

  def shortlist
    raise ActionController::RoutingError, "Cannot shortlist a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?
  end

  def show
    redirect_to organisation_job_job_application_withdrawn_path(vacancy.id, job_application) if job_application.withdrawn?

    raise ActionController::RoutingError, "Cannot view a draft application" if job_application.draft?

    job_application.reviewed! if job_application.submitted?
  end

  def download_pdf
    pdf = JobApplicationPdfGenerator.new(job_application, vacancy).generate

    send_data(
      pdf.render,
      filename: "job_application_#{job_application.id}.pdf",
      type: "application/pdf",
      disposition: "inline",
    )
  end

  def update_status
    raise ActionController::RoutingError, "Cannot shortlist or reject a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?

    job_application.update(form_params.merge(status: status))
    Jobseekers::JobApplicationMailer.send(:"application_#{status}", job_application).deliver_later
    redirect_to organisation_job_job_applications_path(vacancy.id), success: t(".#{status}", name: job_application.name)
  end

  require "zip"

  def download_selected
    # This eliminates all the N+1 issues, but PDF generation still takes ~1.5 seconds per application
    # writing a text string to the PDF seems to take 200ms, and 'closing' the document ~500ms
    downloads = Vacancy
                  .includes(:organisations, :publisher_organisation)
                  .includes(job_applications: [:qualifications, :employments, :training_and_cpds, :references, { jobseeker: :jobseeker_profile }])
                  .find(vacancy.id)
                  .job_applications.select { |job_application| params[:applications].include?(job_application.id) }

    stringio = Zip::OutputStream.write_buffer do |zio|
      downloads.each do |job_application|
        zio.put_next_entry "job_application_#{job_application.id}.pdf"
        logger.debug "generate #{job_application.id}.pdf"
        pdf = JobApplicationPdfGenerator.new(job_application, vacancy).generate
        logger.debug "render #{job_application.id}.pdf"
        zio.write pdf.render
        logger.debug "finished #{job_application.id}.pdf"
      end
    end
    send_data(
      stringio.string,
      filename: "applications_#{vacancy.id}.zip",
      type: "application/zip",
      disposition: "inline",
    )
    # This would seem to do streaming, but the User experience seems very similar
    # and also it doesn't produce a valid Zip file
    # send_stream(
    #   filename: "applications_#{vacancy.id}.zip",
    #   type: "application/zip",
    #   disposition: "inline",
    # ) do |stream|
    #   io = StringIO.new
    #   pos = 0
    #   Zip::OutputStream.write_buffer(io) do |zio|
    #     downloads.each do |job_application|
    #       zio.put_next_entry "job_application_#{job_application.id}.pdf"
    #       zio.write JobApplicationPdfGenerator.new(job_application, vacancy).generate.render
    #
    #       io.seek pos
    #       stream.write io.read
    #       pos = io.size
    #       io.seek pos
    #     end
    #   end
    #   io.seek pos
    #   stream.write io.read
    # end
  end

  private

  def generate_zip(downloads)
    Enumerator.new { |yielder|
      io = StringIO.new
      pos = 0
      Zip::OutputStream.write_buffer(io) do |zio|
        downloads.each do |job_application|
          zio.put_next_entry "job_application_#{job_application.id}.pdf"
          zio.write JobApplicationPdfGenerator.new(job_application, vacancy).generate.render

          io.seek pos
          yielder << io.read
          pos = io.size
        end
      end
      io.seek pos
      yielder << io.read
    }.lazy
  end

  def job_applications
    @job_applications ||= vacancy.job_applications.not_draft
  end

  def sorted_job_applications
    sort.by_db_column? ? job_applications.order(sort.by => sort.order) : job_applications_sorted_by_virtual_attribute
  end

  def job_applications_sorted_by_virtual_attribute
    # When we 'order' by a virtual attribute we have to do the sorting after all scopes.
    # last_name is a virtual attribute as it is an encrypted column.
    job_applications.sort_by(&sort.by.to_sym)
  end

  def form
    @form ||= Publishers::JobApplication::UpdateStatusForm.new
  end

  def form_params
    params.require(:publishers_job_application_update_status_form).permit(:further_instructions, :rejection_reasons)
  end

  def employments
    @employments ||= job_application.employments.order(:started_on)
  end

  def status
    return "shortlisted" if form_params.key?("further_instructions")

    "unsuccessful" if form_params.key?("rejection_reasons")
  end

  def sort
    @sort ||= Publishers::JobApplicationSort.new.update(sort_by: params[:sort_by])
  end
end
