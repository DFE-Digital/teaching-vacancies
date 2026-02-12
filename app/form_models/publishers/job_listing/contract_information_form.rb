class Publishers::JobListing::ContractInformationForm < Publishers::JobListing::JobListingForm
  include ActiveModel::Attributes

  attr_accessor :contract_type, :fixed_term_contract_duration, :working_patterns, :working_patterns_details

  validates :contract_type, inclusion: { in: Vacancy.contract_types.keys }
  validates :working_patterns, presence: true, inclusion: { in: Vacancy::WORKING_PATTERNS }
  validates :fixed_term_contract_duration, presence: true, if: -> { contract_type == "fixed_term" }
  validates :is_parental_leave_cover, inclusion: { in: [true, false] }, if: -> { contract_type == "fixed_term" }
  validates :is_job_share, inclusion: { in: [true, false] }
  validate :working_patterns_details_does_not_exceed_maximum_words

  attribute :is_job_share, :boolean
  attribute :is_parental_leave_cover, :boolean

  WORKING_PATTERNS_DETAILS_MAX_WORDS = 75

  def self.fields
    %i[contract_type fixed_term_contract_duration is_parental_leave_cover working_patterns working_patterns_details is_job_share]
  end

  def params_to_save
    { working_patterns:, working_patterns_details:, is_job_share:, contract_type:, fixed_term_contract_duration:, is_parental_leave_cover: }
  end

  private

  def working_patterns_details_does_not_exceed_maximum_words
    return unless number_of_words_exceeds_permitted_length?(WORKING_PATTERNS_DETAILS_MAX_WORDS, working_patterns_details)

    errors.add(:working_patterns_details,
               :working_patterns_details_maximum_words,
               message: I18n.t("contract_information_errors.working_patterns_details.maximum_words"))
  end
end
