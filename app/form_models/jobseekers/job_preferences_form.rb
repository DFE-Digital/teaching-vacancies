require_dependency "multistep/form"

module Jobseekers
  class JobPreferencesForm
    include Multistep::Form

    ROLES = %i[teacher head_of_year_or_phase head_of_department_or_curriculum assistant_headteacher deputy_headteacher
               headteacher teaching_assistant higher_level_teaching_assistant education_support sendco].freeze
    PHASES = %i[nursery primary middle secondary through].freeze
    WORKING_PATTERNS = %i[full_time part_time].freeze

    def self.from_record(record)
      new(
        **record.attributes.slice(*attribute_names.without("locations")),
        locations: record.locations.to_h { |l| [l.id, { location: l.name, radius: l.radius }] },
      )
    end

    step :roles do
      attribute :roles, array: true

      validates :roles, presence: true
      validate :validate_roles

      def options
        ROLES.to_h { |opt| [opt.to_s, I18n.t("helpers.label.jobseekers_job_preferences_form.role_options.#{opt}")] }
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
          .to_h { |opt| [opt.to_s, I18n.t("jobs.education_phase_options.#{opt}")] }
      end
    end

    step :key_stages do
      attribute :key_stages, array: true
      validates :key_stages, presence: true

      def options(phases: multistep.phases)
        school_types = School::READABLE_PHASE_MAPPINGS.select { |_, v| phases.include? v }.map(&:first)
        School::PHASE_TO_KEY_STAGES_MAPPINGS.values_at(*school_types).flatten.uniq
          .to_h { |opt| [opt.to_s, I18n.t("helpers.label.jobseekers_job_preferences_form.key_stages_options.#{opt}")] }
      end

      def invalidate?
        return false unless multistep.phases_changed?

        options_before, options_after = multistep.changes[:phases].map { |phases| options(phases: phases).keys }
        self.key_stages = key_stages & options_after

        any_new_option = (options_after - options_before).any?
        any_new_option || key_stages.blank?
      end
    end

    step :subjects do
      attribute :subjects, array: true

      def skip?
        return false if multistep.key_stages.intersect?(%w[ks3 ks4 ks5])

        self.subjects = []
        true
      end
    end

    step :working_patterns do
      attribute :working_patterns, array: true

      validates :working_patterns, presence: true

      def options
        WORKING_PATTERNS.to_h { |opt| [opt.to_s, I18n.t("helpers.label.publishers_job_listing_working_patterns_form.working_patterns_options.#{opt}")] }
      end
    end

    step :locations do
      attribute :locations, default: {}
      attribute :add_location, :boolean
      validates :add_location, inclusion: { in: [true, false], message: :blank }
    end

    attribute :builder_completed, :boolean, default: false

    def build_location_form(id)
      return if id.present? && !locations[id]

      attrs = id ? locations[id] : {}
      LocationForm.new(attrs)
    end

    def update_location(id, attributes)
      id ||= SecureRandom.uuid
      (locations[id] ||= {}).merge!(attributes.symbolize_keys)
    end

    def complete_step!(*args)
      super

      self.builder_completed = true if completed?
    end

    def locations=(values)
      super(values.transform_values(&:symbolize_keys))
    end

    def next_step(current_step: nil, **)
      return next_step if current_step && builder_completed

      super
    end

    class LocationForm
      include FormObject

      attribute :location
      attribute :radius

      validates :location, :radius, presence: true
      validate :location_within_united_kingdom

      def radius_options
        [0, 1, 5, 10, 15, 20, 25, 50, 100, 200].map { |radius| [radius, I18n.t("jobs.search.number_of_miles", count: radius)] }
      end

      private

      def location_within_united_kingdom
        unless Geocoder.search(location).map(&:country).include?("United Kingdom")
          errors.add(:location, I18n.t('activemodel.errors.models.jobseekers/job_preferences_form/location_form.attributes.location.blank'))
        end
      end
    end

    class DeleteLocationForm
      include FormObject

      attribute :action
      validates :action, inclusion: { in: %w[edit delete], message: :blank }

      def options
        {
          "edit" => "No, change the location",
          "delete" => "Yes, delete this location and turn off my profile",
        }
      end
    end
  end
end
