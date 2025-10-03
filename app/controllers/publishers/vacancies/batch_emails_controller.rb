module Publishers
  class Vacancies::BatchEmailsController < Vacancies::BaseController
    def select_rejection_template
      session[:template_return_path] = request.original_fullpath
      @batch_email = vacancy.job_application_batches.find(params[:id])
      @job_applications = @batch_email.batchable_job_applications.map(&:job_application)
      @email_templates = email_templates.with_rich_text_content_and_embeds
    end

    def prepare_rejection_emails
      @batch_email = vacancy.job_application_batches.find_by(id: params[:id])
      @job_applications = @batch_email.batchable_job_applications.map(&:job_application)
      email_template = email_templates.find_by(id: params[:email_template])
      @form = JobApplication::RejectionEmailForm.new(subject: email_template.subject,
                                                     content: email_template.content,
                                                     contact_email: current_publisher.email)
    end

    def send_rejection_emails
      batch = vacancy.job_application_batches.find_by(id: params[:id])
      form = JobApplication::RejectionEmailForm.new(send_rejection_emails_params)

      bcc = [form.contact_email] if form.email_copy
      logo_org = vacancy.organisation if form.include_school_logo

      batch.batchable_job_applications.map(&:job_application).each do |job_application|
        BatchRejectionMailer.send_rejection(from: form.from, logo_org: logo_org, bcc: bcc, subject: form.subject,
                                            contact_email: form.contact_email,
                                            content: form.content, job_application: job_application).deliver_later
        job_application.update!(status: :rejected)
      end

      # batch.update!(batch_type: :rejection)

      redirect_to organisation_job_job_applications_path(vacancy.id, anchor: :unsuccessful), success: t(".rejections_sent")
    end

    private

    def email_templates
      current_publisher.email_templates.rejection
    end

    def send_rejection_emails_params
      params.expect(publishers_job_application_rejection_email_form: %i[subject contact_email from content include_school_logo email_copy])
    end
  end
end
