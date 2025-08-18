module Jobseekers
  module JobApplications
    module SelfDisclosure
      class ConfirmationForm < BaseForm
        FIELDS = %i[agreed_for_processing agreed_for_criminal_record agreed_for_organisation_update agreed_for_information_sharing true_and_complete].freeze

        FIELDS.each do |field|
          attribute field, :boolean
          validates field, inclusion: { in: [true] }
        end
      end
    end
  end
end
