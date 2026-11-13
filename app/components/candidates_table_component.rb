# A read-only table of job applications. SelectableCandidatesTableComponent is the version with
# a checkbox for each candidate, for tabs where publishers act on the candidates they select.
class CandidatesTableComponent < ApplicationComponent
  include CandidateCells

  def initialize(vacancy:, candidates:, displayed_fields: %i[name email_address status])
    super()
    @vacancy = vacancy
    @candidates = candidates
    @displayed_fields = displayed_fields
  end
end
