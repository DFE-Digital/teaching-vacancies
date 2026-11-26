class Publishers::JobListing::ContractInformationForm < Publishers::JobListing::JobListingForm
  include ActiveModel::Attributes

  attr_accessor :contract_type, :fixed_term_contract_duration, :working_patterns, :working_patterns_details

  attribute :is_job_share, :boolean
  attribute :is_parental_leave_cover, :boolean

  FIELDS = %i[contract_type fixed_term_contract_duration is_parental_leave_cover working_patterns working_patterns_details is_job_share].freeze

  class << self
    # # rubocop:disable Lint/UnusedMethodArgument
    # def load_from_model(vacancy, current_publisher:)
    #   new(vacancy.slice(*FIELDS))
    # end
    # # rubocop:enable Lint/UnusedMethodArgument

    def fields
      [:working_patterns_details, :is_job_share, :contract_type, :fixed_term_contract_duration, :is_parental_leave_cover, { working_patterns: [] }]
    end

    def field_list
      FIELDS
    end
  end

  def params_to_save
    { working_patterns:, working_patterns_details:, is_job_share:, contract_type:, fixed_term_contract_duration:, is_parental_leave_cover: }
  end
end
