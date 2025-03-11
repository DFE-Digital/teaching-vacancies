class Publishers::JobListing::ContractInformationForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes
  attr_accessor :contract_type, :fixed_term_contract_duration, :is_parental_leave_cover, :working_patterns, :working_patterns_details, :is_job_share

  validates :working_patterns, presence: true, inclusion: { in: Vacancy::WORKING_PATTERNS }
  validates :fixed_term_contract_duration, presence: true, if: -> { contract_type == "fixed_term" }
  validates :is_parental_leave_cover, inclusion: { in: [true, false] }, if: -> { contract_type == "fixed_term" }
  validates :working_patterns, presence: true, inclusion: { in: Vacancy.working_patterns.keys - %w[job_share] }
  validates :is_job_share, inclusion: { in: [true, false] }
  validate :working_patterns_details_does_not_exceed_maximum_words

  attribute :working_patterns, array: true, default: []
  attribute :working_patterns_details
  attribute :is_job_share, :boolean
  attribute :contract_type
  attribute :fixed_term_contract_duration
  attribute :is_parental_leave_cover, :boolean

  class << self
    # Overriding load_form because we use attributes in this form rather than defining the fields like we do in other forms.
    # This is necessary as we need to define working_patterns explicitly as an array.
    def load_form(model)
      model.slice(*attribute_names)
    end
  end

  def params_to_save
    { working_patterns:, working_patterns_details:, is_job_share:, contract_type:, fixed_term_contract_duration:, is_parental_leave_cover: }
  end

  private

  def working_patterns_details_does_not_exceed_maximum_words
    return unless number_of_words_exceeds_permitted_length?(75, working_patterns_details)

    errors.add(:working_patterns_details,
               :working_patterns_details_maximum_words,
               message: I18n.t("contract_information_errors.working_patterns_details.maximum_words"))
  end
end
