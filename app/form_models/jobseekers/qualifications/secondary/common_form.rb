module Jobseekers::Qualifications::Secondary
  class CommonForm < ::Jobseekers::Qualifications::QualificationForm
    MAXIMUM_NUMBER_OF_RESULTS = 6

    attr_accessor :qualification_results

    validate :at_least_one_qualification_result
    validate :all_qualification_results_valid
    validates :institution, presence: true
    validates :year, numericality: { less_than_or_equal_to: proc { Time.current.year } }

    def initialize(attributes = nil)
      super
      pad_qualification_results
    end

    def qualification_results_attributes=(attrs)
      @qualification_results = attrs.map { |_, params| QualificationResultForm.new(params) }
    end

    # Required to allow us to add qualification results form field errors to this form (its parent)
    # in `#all_qualification_results_valid` so they show up in the GOV.UK Error Summary. The
    # default `#read_attribute_for_validation` is aliased to `send(attr)`, which fails because
    # these methods (e.g. qualification_results_attributes_3_grade) aren't defined. We don't need
    # to actually return anything meaningful for these virtual attributes as the actual validation
    # for the fields happens in the `QualificationResultForm`.
    def read_attribute_for_validation(attr)
      super unless /^qualification_results_attributes_/.match?(attr)
    end

    def highest_present_result_index
      @highest_present_result_index ||= qualification_results.map.with_index { |result, index| index unless result.empty? }.compact.last || 0
    end

    private

    def at_least_one_qualification_result
      return if qualification_results.reject(&:empty?).any?

      errors.add(:qualification_results_attributes_0_subject, :at_least_one_result_required)

      # Force first results form to validate so the first set of fields shows an error state on the form
      qualification_results.first.valid?
    end

    def all_qualification_results_valid
      qualification_results.each_with_index do |result, idx|
        next if result.empty? || result.valid?

        attr = result.errors.attribute_names.first
        errors.add(:"qualification_results_attributes_#{idx}_#{attr}", :incomplete_qualification_result, attribute: attr, result_idx: idx + 1)
      end
    end

    def pad_qualification_results
      # Ensures the number of QualificationResults present in the form are the highest of:
      #   - however many are already there (in case we lower the maximum number in the future), or
      #   - the maximum number we want to have
      # by padding the qualification results with empty objects
      @qualification_results ||= []
      @qualification_results += [QualificationResultForm.new] * [MAXIMUM_NUMBER_OF_RESULTS - qualification_results.count, 0].max
    end
  end
end
