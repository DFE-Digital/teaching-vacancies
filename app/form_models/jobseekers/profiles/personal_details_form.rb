module Jobseekers::Profiles
  class PersonalDetailsForm
    STEPS = { name: %i[first_name last_name],
              phone_number: %i[phone_number_provided phone_number],
              work: [:has_right_to_work_in_uk] }.freeze

    class << self
      def from_record(record)
        new record
      end

      # TODO: - simplify view so this method can be deleted
      def delegated_attributes
        STEPS.invert.map { |kl, v| kl.map { |k| { k => v } }.reduce(&:merge) }.reduce(&:merge)
      end
    end

    def initialize(record)
      @personal_details = record
    end

    def next_invalid_step
      FORMS.drop_while { |step, form_class|
        form_class.new(@personal_details.slice(STEPS.fetch(step))).valid?
      }.first.first
    end

    class PersonalDetailsForm < ::BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
    end

    class NamesForm < PersonalDetailsForm
      attribute :first_name
      attribute :last_name

      validates :first_name, :last_name, presence: true

      class << self
        def fields
          %i[first_name last_name]
        end
      end

      def params_to_save
        { first_name: first_name, last_name: last_name }
      end
    end

    class PhoneNumberForm < PersonalDetailsForm
      attribute :phone_number_provided
      attribute :phone_number

      validates :phone_number_provided, presence: true
      validates :phone_number, presence: true, format: { with: /\A\+?(?:\d\s?){10,13}\z/ }, if: -> { phone_number_provided == "true" }

      class << self
        def fields
          %i[phone_number_provided phone_number]
        end
      end

      def params_to_save
        { phone_number: phone_number, phone_number_provided: phone_number_provided }
      end
    end

    class WorkForm < PersonalDetailsForm
      attribute :has_right_to_work_in_uk, :boolean

      validates :has_right_to_work_in_uk, inclusion: { in: [true, false] }

      class << self
        def fields
          [:has_right_to_work_in_uk]
        end
      end

      def params_to_save
        { has_right_to_work_in_uk: has_right_to_work_in_uk }
      end
    end

    FORMS = {
      name: NamesForm,
      phone_number: PhoneNumberForm,
      work: WorkForm,
    }.freeze
  end
end
