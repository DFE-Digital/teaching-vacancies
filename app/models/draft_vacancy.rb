# frozen_string_literal: true

class DraftVacancy < Vacancy
  # :nocov:
  def trash!
    destroy!
  end
  # :nocov:

  def draft?
    true
  end

  def expired?
    false
  end

  def published?
    false
  end
end
