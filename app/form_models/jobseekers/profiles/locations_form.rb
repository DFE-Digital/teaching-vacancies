# frozen_string_literal: true

module Jobseekers
  module Profiles
    class LocationsForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      class << self
        def field_names
          [:locations]
        end
      end

      attribute :locations, default: []
      attribute :add_location, :boolean
      validates :add_location, inclusion: { in: [true, false], message: :blank }
    end
  end
end
