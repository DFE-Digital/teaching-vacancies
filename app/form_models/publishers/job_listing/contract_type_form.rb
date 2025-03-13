class Publishers::JobListing::ContractTypeForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  attr_accessor :contract_type, :fixed_term_contract_duration

  attribute :is_parental_leave_cover, :boolean

  validates :contract_type, inclusion: { in: Vacancy.contract_types.keys }
  validates :fixed_term_contract_duration, presence: true, if: -> { contract_type == "fixed_term" }
  validates :is_parental_leave_cover, inclusion: { in: [true, false] }, if: -> { contract_type == "fixed_term" }

  def self.fields
    %i[contract_type fixed_term_contract_duration is_parental_leave_cover]
  end
end
