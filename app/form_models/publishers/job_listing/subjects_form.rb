class Publishers::JobListing::SubjectsForm < Publishers::JobListing::JobListingForm
  FIELDS = %i[subjects].freeze

  class << self
    # rubocop:disable Lint/UnusedMethodArgument
    def load_from_model(vacancy, current_publisher:)
      new(vacancy.slice(*FIELDS))
    end
    # rubocop:enable Lint/UnusedMethodArgument

    def fields
      { subjects: [] }
    end
  end
  attr_accessor(*FIELDS)
  attr_accessor :subject_search

  validate :subject_search_must_be_selected

  def params_to_save
    { subjects: subjects.compact_blank }
  end

  private

  def subject_search_must_be_selected
    return if subject_search.blank?
    return if subjects.present?

    errors.add(:subject_search, I18n.t("publishers.vacancies.build.subjects.errors.subject_searched_for_but_not_selected"))
  end
end
