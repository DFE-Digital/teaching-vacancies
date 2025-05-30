# frozen_string_literal: true

class DraftVacancy < Vacancy
  def trash!
    destroy!
  end
end
