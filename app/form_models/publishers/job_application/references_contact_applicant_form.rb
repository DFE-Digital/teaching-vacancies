module Publishers
  module JobApplication
    class ReferencesContactApplicantForm
      include ActiveModel::Model
      include ActiveModel::Validations
      include ActiveModel::Attributes

      FIELDS = %i[collect_references contact_applicants].freeze

      FIELDS.each do |field|
        attribute field, :boolean
      end

      validates :contact_applicants, inclusion: { in: [true, false], allow_nil: false }

      class << self
        def fields
          FIELDS
        end
      end
    end
  end
end
