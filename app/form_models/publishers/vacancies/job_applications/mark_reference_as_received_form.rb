module Publishers
  module Vacancies
    module JobApplications
      class MarkReferenceAsReceivedForm
        include ActiveModel::Model
        include ActiveModel::Validations
        include ActiveModel::Attributes

        ATTRIBUTES = [:reference_satisfactory].freeze

        ATTRIBUTES.each do |field|
          attribute field, :boolean
          validates field, inclusion: { in: [true, false], allow_nil: false }
        end
      end
    end
  end
end
