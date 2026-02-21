# frozen_string_literal: true

module Jobseekers
  module Profiles
    class RolesForm < ProfilesForm
      ROLES = %i[teacher
                 head_of_year_or_phase
                 head_of_department_or_curriculum
                 assistant_headteacher
                 deputy_headteacher
                 headteacher
                 teaching_assistant
                 higher_level_teaching_assistant
                 education_support
                 sendco
                 administration_hr_data_and_finance
                 catering_cleaning_and_site_management
                 it_support
                 pastoral_health_and_welfare
                 other_leadership
                 other_support].freeze

      class << self
        def fields
          { roles: [] }
        end
      end

      def params_to_save
        { roles: roles }
      end

      attribute :roles, array: true

      validates :roles, presence: true
      validate :validate_roles

      def teaching_job_roles_options
        Vacancy::TEACHING_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.teaching_job_role_options.#{option}")] }
      end

      def support_job_roles_options
        Vacancy::SUPPORT_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.#{option}")] }
      end

      def options
        ROLES.to_h { |opt| [opt.to_s, I18n.t("helpers.label.jobseekers_job_preferences_form.role_options.#{opt}")] }
      end

      def validate_roles
        return if (roles.compact_blank - ROLES.map(&:to_s)).empty?

        errors.add(:roles, :invalid)
      end
    end
  end
end
