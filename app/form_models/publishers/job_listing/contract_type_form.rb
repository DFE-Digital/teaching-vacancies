class Publishers::JobListing::ContractTypeForm < Publishers::JobListing::VacancyForm
  attr_accessor :contract_type, :fixed_term_contract_duration, :parental_leave_cover_contract_duration

  validates :contract_type, inclusion: { in: Vacancy.contract_types.keys }
  validates :fixed_term_contract_duration, presence: true, if: -> { contract_type == "fixed_term" }
  validates :parental_leave_cover_contract_duration, presence: true, if: -> { contract_type == "parental_leave_cover" }

  def self.fields
    %i[contract_type fixed_term_contract_duration parental_leave_cover_contract_duration]
  end
end
