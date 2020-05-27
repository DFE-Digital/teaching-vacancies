module GetSubjectName
  SUBJECT_SYNONYMS = {
    'Maths': 'Mathematics',
    'English Literature': 'English',
    'English Language': 'English'
  }.stringify_keys

  def get_subject_name(subject)
    return nil if subject.blank?

    subject_option_names = Vacancy::SUBJECT_OPTIONS.map { |subject_option| subject_option.first }

    return subject.name if subject_option_names.include?(subject.name)
    return SUBJECT_SYNONYMS[subject.name] if subject_option_names.include?(SUBJECT_SYNONYMS[subject.name])
    nil
  end
end
