# frozen_string_literal: true

module Publishers
  module JobListing
    class AnonymiseApplicationsForm < JobListingForm
      class << self
        def fields
          [:anonymise_applications]
        end
      end

      attribute :anonymise_applications, :boolean
      validates :anonymise_applications, inclusion: { in: [true, false], allow_nil: false }
    end
  end
end
