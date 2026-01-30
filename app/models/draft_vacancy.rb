# frozen_string_literal: true

class DraftVacancy < Vacancy
  def trash!
    destroy!
  end

  def draft?
    true
  end

  def expired?
    false
  end

  def published?
    false
  end

  def applicable?
    false
  end
end
