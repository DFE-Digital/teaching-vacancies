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

  validate :subjects_must_be_from_list
  validate :subject_search_must_be_selected

  def params_to_save
    { subjects: subjects.compact_blank }
  end

  private

  def subjects_must_be_from_list
    valid_subjects = (SUBJECT_OPTIONS + FURTHER_EDUCATION_SUBJECT_OPTIONS).map(&:first)
    Array(subjects).compact_blank.each do |subject|
      unless valid_subjects.include?(subject)
        errors.add(:subjects, I18n.t("publishers.vacancies.build.subjects.errors.not_in_list"))
        break
      end
    end
  end

  def subject_search_must_be_selected
    return if subject_search.blank?
    return if Array(subjects).compact_blank.any?

    errors.add(:subject_search, I18n.t("publishers.vacancies.build.subjects.errors.not_in_list"))
  end
end
