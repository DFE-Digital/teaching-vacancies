module Jobseekers::JobApplication::Details::Qualifications::Secondary
  class CommonForm < ::Jobseekers::JobApplication::Details::Qualifications::QualificationForm
    MAXIMUM_NUMBER_OF_RESULTS = 6

    validates :institution, :year, presence: true
    validates :year, format: { with: /\A\d{4}\z/.freeze }, if: -> { year.present? }
    validate :at_least_one_qualification_result
    validate :all_qualification_results_valid

    def initialize(attributes = nil)
      super(attributes)
      pad_qualification_results
    end

    def qualification_results_attributes=(attrs)
      @qualification_results ||= []
      attrs.each do |_idx, qualification_params|
        @qualification_results.push(QualificationResultForm.new(qualification_params))
      end
    end

    private

    def at_least_one_qualification_result
      return if qualification_results.reject(&:empty?).any?

      errors.add(:base, :at_least_one_result_required)

      # Force first results form to validate so the first set of fields shows an error state on the form
      qualification_results.first.valid?
    end

    def all_qualification_results_valid
      qualification_results.each_with_index do |result, idx|
        next if result.empty? || result.valid?

        errors.add(:base, :incomplete_result)
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
