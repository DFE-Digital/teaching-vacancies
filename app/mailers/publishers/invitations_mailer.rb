module Publishers
  class InvitationsMailer < BaseMailer
    def invite_to_apply(job_ids:, jobseeker_id:, publisher_id:, organisation_id:)
      @jobs = Vacancy.where(id: job_ids)

      jobseeker = Jobseeker.find(jobseeker_id)
      publisher = Publisher.find(publisher_id)
      organisation = ::Organisation.find(organisation_id)

      @jobseeker_name = jobseeker.jobseeker_profile.personal_details.first_name
      @publisher_name = publisher.given_name
      @organisation_name = organisation.name

      @subject = I18n.t("publishers.invitations_mailer.invite_to_apply.subject")

      view_mail(template, to: jobseeker.email, subject: @subject)
    end
  end
end
