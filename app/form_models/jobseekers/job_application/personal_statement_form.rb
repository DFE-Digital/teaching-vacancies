module Jobseekers
  module JobApplication
    class PersonalStatementForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      FIELDS = %i[personal_statement_richtext].freeze

      class << self
        def storable_fields
          FIELDS
        end

        def unstorable_fields
          %i[personal_statement_section_completed]
        end

        def load_form(model)
          super.merge(completed_attrs(model, :personal_statement))
        end
      end
      attr_accessor(*FIELDS)

      validates :personal_statement_richtext, presence: true, if: -> { personal_statement_section_completed }
      validate :word_count_within_limit, if: -> { personal_statement_section_completed && personal_statement_richtext.present? }

      completed_attribute(:personal_statement)

      private

      def word_count_within_limit
        word_count = personal_statement_richtext.strip.split(/\s+/).reject(&:empty?).length
        return if word_count <= 1500

        errors.add(:personal_statement_richtext, "must be 1,500 words or fewer (currently #{word_count} words)")
      end
    end
  end
end
