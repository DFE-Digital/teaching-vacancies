base_path = Rails.root.join("config/data")

SUBJECT_OPTIONS = YAML.load_file(base_path.join("subjects.yml"))
FURTHER_EDUCATION_SUBJECT_OPTIONS = YAML.load_file(base_path.join("further_education_subjects.yml"))
VACANCY_SEARCH_SUBJECT_OPTIONS = (SUBJECT_OPTIONS + FURTHER_EDUCATION_SUBJECT_OPTIONS)
  .uniq { |subject, _hint| subject.downcase }
  .sort_by { |subject, _hint| subject.downcase }
