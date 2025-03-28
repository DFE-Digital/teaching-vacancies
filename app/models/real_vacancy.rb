# frozen_string_literal: true

class RealVacancy < Vacancy
  def draft?
    false
  end
end
