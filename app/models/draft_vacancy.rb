# frozen_string_literal: true

class DraftVacancy < Vacancy
  def draft?
    true
  end
end
