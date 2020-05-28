module GetSubjectName
  SUBJECT_SYNONYMS = {
    'Art': 'Art and design',
    'Design Technology': 'Design and technology',
    'English Literature': 'English',
    'English Language': 'English',
    'Health and Social care': 'Health and social care',
    'Latin': 'Classics',
    'Maths': 'Mathematics',
    'Media Studies': 'Media studies',
    'Physical Education': 'Physical education',
    'Religious Studies': 'Religious education',
    'General Science': 'Science'
  }.stringify_keys

  def get_subject_name(subject)
    return nil if subject.blank?

    subject_option_names = SUBJECT_OPTIONS.map(&:first)

    return subject.name if subject_option_names.include?(subject.name)
    return SUBJECT_SYNONYMS[subject.name] if subject_option_names.include?(SUBJECT_SYNONYMS[subject.name])
    nil
  end
end
