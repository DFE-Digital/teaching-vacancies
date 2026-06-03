# frozen_string_literal: true

module JobPreferencesHelper
  def humanize_subjects(subjects)
    subjects.map(&:humanize).join(", ")
  end
end
