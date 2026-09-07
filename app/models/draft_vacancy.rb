# frozen_string_literal: true

class DraftVacancy < Vacancy
  # simplecov:disable
  def trash!
    destroy!
  end
  # simplecov:enable

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
