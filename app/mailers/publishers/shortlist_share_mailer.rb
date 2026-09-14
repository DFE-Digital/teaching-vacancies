# frozen_string_literal: true

require "stringio"

module Publishers
  class ShortlistShareMailer < BaseMailer
    FILE_RETENTION_PERIOD = "1 week"
    TEMPLATE_ID = "d3bf210d-4cb4-4239-aaea-803435a7a4c2"

    def shortlist(vacancy_id, job_application_ids, recipient_email, publisher_id)
      @publisher = Publisher.find(publisher_id)
      @to = recipient_email

      vacancy = Vacancy.find(vacancy_id)
      job_applications = vacancy.job_applications.where(id: job_application_ids)

      raise ActiveRecord::RecordNotFound if job_applications.size != job_application_ids.size
      raise ArgumentError, "Uploaded application forms are not supported" if vacancy.uploaded_form?
      unless valid_selection?(job_applications)
        raise ArgumentError, "Select between 1 and #{Publishers::JobApplication::ShortlistShareForm::MAX_APPLICATIONS} shortlisted applications"
      end

      template_mail(
        TEMPLATE_ID,
        to: recipient_email,
        personalisation: {
          job_title: vacancy.job_title,
          organisation_name: vacancy.organisation_name,
        }.merge(application_personalisation(job_applications)),
      )
    end

    private

    def valid_selection?(job_applications)
      job_applications.size.between?(1, Publishers::JobApplication::ShortlistShareForm::MAX_APPLICATIONS) &&
        job_applications.all?(&:shortlisted?)
    end

    def application_personalisation(job_applications)
      sorted_applications = job_applications.sort_by { |job_application| [job_application.last_name, job_application.first_name] }

      (1..Publishers::JobApplication::ShortlistShareForm::MAX_APPLICATIONS).each_with_object({}) do |position, personalisation|
        job_application = sorted_applications[position - 1]

        personalisation[:"applicant_name_#{position}"] = job_application&.name.to_s
        personalisation[:"application_#{position}"] = job_application ? prepare_application(job_application, position - 1) : ""
      end
    end

    def prepare_application(job_application, index)
      presenter = JobApplicationPdf.new(job_application)
      pdf_data = JobApplicationPdfGenerator.new(presenter).generate.render

      Notifications.prepare_upload(
        StringIO.new(pdf_data),
        filename: "#{index + 1}-#{job_application.name.parameterize}-application.pdf",
        confirm_email_before_download: true,
        retention_period: FILE_RETENTION_PERIOD,
      )
    end
  end
end
