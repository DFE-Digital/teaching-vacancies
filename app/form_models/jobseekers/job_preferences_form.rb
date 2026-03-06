module Jobseekers
  class JobPreferencesForm
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

    WORKING_PATTERNS = %w[full_time part_time job_share].freeze

    STEPS = { roles: [:roles],
              phases: [:phases],
              key_stages: [:key_stages],
              subjects: [:subjects],
              working_patterns: %i[working_patterns working_pattern_details],
              locations: [:locations] }.freeze

    class << self
      def from_record(record)
        new(record)
      end

      # TODO: - simplify view so this method can be deleted
      def delegated_attributes
        STEPS.invert.map { |kl, v| kl.map { |k| { k => v } }.reduce(&:merge) }.reduce(&:merge)
      end
    end

    class ProfilesForm < ::BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      class << self
        def field_names
          fields.map { |f| f.is_a?(Hash) ? f.keys.first : f }
        end
      end

      def skip?(_model)
        false
      end
    end

    class RolesForm < ProfilesForm
      class << self
        def fields
          [{ roles: [] }]
        end
      end

      def params_to_save
        { roles: roles.compact_blank }
      end

      attribute :roles, array: true, default: []

      validates :roles, presence: true
      validate :validate_roles

      def teaching_job_roles_options
        Vacancy::TEACHING_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.teaching_job_role_options.#{option}")] }
      end

      def support_job_roles_options
        Vacancy::SUPPORT_JOB_ROLES.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.#{option}")] }
      end

      def validate_roles
        return if (roles - ROLES.map(&:to_s)).empty?

        errors.add(:roles, :invalid)
      end
    end

    class PhasesForm < ProfilesForm
      class << self
        def fields
          [{ phases: [] }]
        end
      end

      def params_to_save
        { phases: phases }
      end

      attribute :phases, array: true, default: []
      validates :phases, presence: true

      def options
        School::READABLE_PHASE_MAPPINGS.values.uniq.compact
                                       .to_h { |opt| [opt.to_s, I18n.t("jobs.education_phase_options.#{opt}")] }
      end
    end

    class KeyStagesForm < ProfilesForm
      class << self
        def fields
          [{ key_stages: [] }]
        end
      end

      def params_to_save
        { key_stages: key_stages }
      end

      attribute :key_stages, array: true, default: []
      validates :key_stages, presence: true
    end

    class SubjectsForm < ProfilesForm
      class << self
        def fields
          [{ subjects: [] }]
        end
      end

      def params_to_save
        { subjects: subjects }
      end

      attribute :subjects, array: true

      def skip?(model)
        return false if model.key_stages.intersect?(%w[ks3 ks4 ks5])

        self.subjects = []
        true
      end
    end

    class WorkingPatternsForm < ProfilesForm
      class << self
        def fields
          [{ working_patterns: [] }, :working_pattern_details]
        end
      end

      def params_to_save
        {
          working_patterns: working_patterns,
          working_pattern_details: working_pattern_details,
        }
      end

      attribute :working_patterns, array: true
      attribute :working_pattern_details

      validates :working_patterns, presence: true
      validates :working_pattern_details_words, length: { maximum: 50 }, if: -> { working_pattern_details.present? }

      def options
        WORKING_PATTERNS.index_with { |opt| I18n.t("helpers.label.publishers_job_listing_contract_information_form.working_patterns_options.#{opt}") }
      end

      private

      def working_pattern_details_words
        working_pattern_details.scan(/\w+/)
      end
    end

    def initialize(record)
      @job_preferences = record
    end

    def next_invalid_step
      FORMS.drop_while { |step, form_class|
        if step == :subjects
          @job_preferences.completed_steps.symbolize_keys.include?(:subjects)
        else
          form_class.new(@job_preferences.slice(STEPS.fetch(step))).valid?
        end
      }.first.first
    end

    FORMS = {
      roles: RolesForm,
      phases: PhasesForm,
      key_stages: KeyStagesForm,
      subjects: SubjectsForm,
      working_patterns: WorkingPatternsForm,
      locations: Jobseekers::Profiles::LocationsForm,
    }.freeze
  end
end
