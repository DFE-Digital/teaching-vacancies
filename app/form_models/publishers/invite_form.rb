require_dependency "multistep/form"

module Publishers
  class InviteForm
    include Multistep::Form

    Option = Struct.new(:value, :label, :hint)

    attribute :jobseeker_profile_id
    attribute :organisation_id
    attribute :publisher_id

    step :jobs do
      attribute :job_ids, array: true
      validates :job_ids, presence: { message: :what }

      def job_options
        @job_options ||= multistep.applicable_jobs.map { |job| new_option(job) }
      end

      def new_option(job)
        hint = job.job_roles.map { |role|
          I18n.t(role, scope: "helpers.label.publishers_job_listing_job_role_form.job_role_options")
        }.join(", ")
        Option.new(job.id, job.job_title, hint)
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
      personal_details = jobseeker_profile.personal_details
      [personal_details.first_name, personal_details.last_name].join(" ")
    end

    def jobseeker_profile
      @jobseeker_profile ||= JobseekerProfile.find(jobseeker_profile_id)
    end

    def job_preferences
      jobseeker_profile.job_preferences
    end

    def organisation
      @organisation ||= ::Organisation.find(organisation_id)
    end

    def applicable_jobs
      existing_invitations = InvitationToApply.where(jobseeker_id: jobseeker_profile.jobseeker_id)
      @applicable_jobs ||= job_preferences
        .vacancies(organisation.all_vacancies.active.live)
        .where.not(id: existing_invitations.select(:vacancy_id))
    end

    def selected_jobs
      @selected_jobs ||= Vacancy.where(id: job_ids)
    end

    def invitations
      @invitations ||= job_ids.map do |job_id|
        InvitationToApply.new(
          vacancy_id: job_id,
          invited_by_id: publisher_id,
          jobseeker_id: jobseeker_profile.jobseeker_id,
        )
      end
    end

    def mail
      @mail ||= InvitationsMailer.invite_to_apply(
        job_ids: job_ids,
        jobseeker_id: jobseeker_profile.jobseeker_id,
        publisher_id: publisher_id,
        organisation_id: organisation_id,
      )
    end

    def mail_preview
      Kramdown::Document.new(mail.body.to_s).to_html.gsub(%r{</?h\d}) do |match|
        # We need convert all h1 headers into h3. H1 are the only headers rendered in the email, but it would raise
        # accessibility issue when rendered in the view
        match[0..-2] + (match.last.to_i + 2).to_s
      end
    end
  end
end
