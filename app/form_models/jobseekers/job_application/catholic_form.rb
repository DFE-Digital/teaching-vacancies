module Jobseekers
  module JobApplication
    class CatholicForm < ReligiousInformationForm
      include DateAttributeAssignment

      FIELDS = %i[baptism_certificate
                  baptism_address].freeze

      class << self
        def storable_fields
          super + FIELDS + [:baptism_date]
        end

        def unstorable_fields
          %i[catholic_section_completed]
        end

        def load_form(model)
          model.slice(*storable_fields).merge(completed_attrs(model, :catholic))
        end
      end

      attr_accessor(*FIELDS)

      attr_reader(:baptism_date)

      validates :religious_reference_type,
                inclusion: { in: ::JobApplication::RELIGIOUS_REFERENCE_TYPES.keys.map(&:to_s), nil: false },
                if: -> { catholic_section_completed && following_religion }

      completed_attribute(:catholic)

      with_options if: -> { section_completed && following_religion && religious_reference_type == "baptism_date" } do
        validates :baptism_address, presence: true
        validates :baptism_date, date: { on_or_before: :today }
      end

      with_options if: -> { section_completed && following_religion && religious_reference_type == "baptism_certificate" } do
        validates :baptism_certificate, form_file: Vacancy::DOCUMENT_VALIDATION_OPTIONS.merge(skip_google_drive_virus_check: true), presence: true
        # Files awaiting an antivirus scan are allowed to progress through the wizard steps so jobseekers can complete other steps.
        # Pending files are blocked at submit time in the review form.
        validate :baptism_certificate_scan_safe
      end

      def baptism_date=(value)
        @baptism_date = date_from_multiparameter_hash(value)
      end

      def section_completed
        catholic_section_completed
      end

      private

      def baptism_certificate_scan_safe
        return unless baptism_certificate.respond_to?(:blob)

        blob = baptism_certificate.blob
        errors.add(:baptism_certificate, :unsafe_file, filename: blob.filename) if blob.malware_scan_malicious? || blob.malware_scan_scan_error?
      end
    end
  end
end
