require_dependency 'multistep/form'

module Jobseekers
  class JobPreferencesForm
    include Multistep::Form

    ROLES = %i[teacher senior_leader middle_leader  teaching_assistant higher_level_teaching_assistant education_support sendco].freeze
    PHASES = %i[nursery primary middle secondary through]

    step :roles do
      attribute :roles, array: true

      validates :roles, presence: true
      validate :validate_roles

      def options
        ROLES.map {|opt| [opt.to_s, I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{opt}")]}
      end

      def validate_roles
        return if (roles - ROLES.map(&:to_s)).empty?

        errors.add(:roles, :invalid)
      end
    end

    step :phases do
      attribute :phases, array: true

      validates :phases, presence: true

      def options
        PHASES.map {|opt| [opt.to_s, I18n.t("jobs.education_phase_options.#{opt}")]}
      end
    end
  end
end
