# frozen_string_literal: true

module Jobseekers
  module Profiles
    class LocationsForm < ProfilesForm
      class << self
        def fields
          { locations: [] }
        end
      end

      def params_to_save
        { locations: locations }
      end

      attribute :locations, default: {}
      attribute :add_location, :boolean
      validates :add_location, inclusion: { in: [true, false], message: :blank }
    end
  end
end
