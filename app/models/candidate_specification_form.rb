class CandidateSpecificationForm < VacancyForm

  validates :essential_requirements, presence: true
end
