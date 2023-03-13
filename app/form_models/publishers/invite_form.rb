require_dependency "multistep/form"

module Publishers
  class InviteForm
    include Multistep::Form

    Option = Struct.new(:value, :label, :hint)

    attribute :jobseeker_id
    attribute :organisation_id
    attribute :publisher_id

    step :jobs do
      attribute :job_ids, array: true
      validates :job_ids, presence: { message: :what }

      def job_options
        @job_options ||= multistep.applicable_jobs.map do |job|
          Option.new(job.id, job.job_title, I18n.t(job.job_role, scope: 'helpers.label.publishers_job_listing_job_role_form.job_role_options'))
        end
      end
    end

    step :review

    def complete!
      ApplicationRecord.transaction do
        invitations.each(&:save!)
      end

      mail.deliver_later
    end

    def jobseeker_name
      personal_details = jobseeker.jobseeker_profile.personal_details
      [personal_details.first_name, personal_details.last_name].join(' ')
    end

    def jobseeker
      @jobseeker ||= Jobseeker.find(jobseeker_id)
    end

    def job_preferences
      jobseeker.jobseeker_profile.job_preferences
    end

    def organisation
      @organisation ||= ::Organisation.find(organisation_id)
    end

    def applicable_jobs
      @job_options ||= job_preferences.vacancies(organisation.vacancies.active)
    end

    def selected_jobs
      @selected_jobs ||= Vacancy.where(id: job_ids)
    end

    def invitations
      @invitations ||= job_ids.map do |job_id|
        InvitationToApply.new(
          vacancy_id: job_id,
          invited_by_id: publisher_id,
          jobseeker_id: jobseeker_id
        )
      end
    end

    def mail
      @mail ||= InvitationsMailer.invite_to_apply(
        job_ids: job_ids,
        jobseeker_id: jobseeker_id,
        publisher_id: publisher_id,
        organisation_id: organisation_id,
      )
    end

    def mail_preview
      Kramdown::Document.new(mail.body.to_s).to_html
    end
  end
end
