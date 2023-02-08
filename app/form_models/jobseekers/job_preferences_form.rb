require_dependency 'multistep/form'

module Jobseekers
  class JobPreferencesForm
    include Multistep::Form

    ROLES = %i[teacher senior_leader middle_leader  teaching_assistant higher_level_teaching_assistant education_support sendco].freeze
    PHASES = %i[nursery primary middle secondary through]
    WORKING_PATTERNS = %i[flexible full_time job_share part_time term_time]

    def self.from_record(record)
      new record.attributes.slice(*self.attribute_names)
    end

    step :roles do
      attribute :roles, array: true

      validates :roles, presence: true
      validate :validate_roles

      def options
        ROLES.to_h {|opt| [opt.to_s, I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{opt}")]}
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
        School::READABLE_PHASE_MAPPINGS.values.uniq.compact
          .to_h {|opt| [opt.to_s, I18n.t("jobs.education_phase_options.#{opt}")]}
      end
    end

    step :key_stages do
      attribute :key_stages, array: true
      validates :key_stages, presence: true

      def options
        school_types = School::READABLE_PHASE_MAPPINGS.select {|_,v| multistep.phases.include? v }.map(&:first)
        School::PHASE_TO_KEY_STAGES_MAPPINGS.values_at(*school_types).flatten.uniq
          .to_h {|opt| [opt.to_s, I18n.t("helpers.label.publishers_job_listing_key_stages_form.key_stages_options.#{opt}")]}
      end

      def invalidate?
        (key_stages - options.keys).any?
      end
    end

    step :working_patterns do
      attribute :working_patterns, array: true

      validates :working_patterns, presence: true

      def options
        WORKING_PATTERNS.to_h {|opt| [opt.to_s, I18n.t("helpers.label.publishers_job_listing_working_patterns_form.working_patterns_options.#{opt}") ]}
      end
    end

    step :locations do
      attribute :locations, array: true
      attribute :add_location, :boolean
      validates :add_location, inclusion: { in: [true, false], message: :blank }
    end

    def build_location_form(id)
      return if id.present? && !locations[id]

      attrs = id ? locations[id] : {}
      LocationForm.new(attrs)
    end

    def update_location(id, attributes)
      if id
        locations[id].merge!(attributes)
      else
        locations << attributes
      end
    end

    def locations=(values)
      super values.map(&:symbolize_keys)
    end

    def next_step(current_step: nil)
      return if current_step && completed?

      super
    end

    class LocationForm
      include FormObject

      attribute :location
      attribute :radius

      validates :location, :radius, presence: true

      def radius_options
        [0, 1,5, 10, 15, 20, 25, 50, 100, 200].map {|radius| [radius, I18n.t("jobs.search.number_of_miles", count: radius)]}
      end
    end
  end
end
