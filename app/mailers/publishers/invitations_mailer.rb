module Publishers
  class InvitationsMailer < BaseMailer
    def invite_to_apply(job_ids:, jobseeker_id:, publisher_id:, organisation_id:)
      @vacancies = Vacancy.where(id: job_ids)

      jobseeker = Jobseeker.find(jobseeker_id)

      @jobseeker_name = jobseeker.jobseeker_profile.personal_details.first_name
      @publisher_name = Publisher.find(publisher_id).given_name
      @organisation_name = ::Organisation.find(organisation_id).name

      @subject = I18n.t("publishers.invitations_mailer.invite_to_apply.subject", count: @vacancies.count)

      view_mail(template, to: jobseeker.email, subject: @subject)
    end
  end
end
