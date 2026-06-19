base_path = Rails.root.join("config/data")

SUBJECT_OPTIONS = YAML.load_file(base_path.join("subjects.yml"))
FURTHER_EDUCATION_SUBJECT_OPTIONS = YAML.load_file(base_path.join("further_education_subjects.yml"))

# de-duplicated list - use this for JebSeeker side when we don't know FE/School,
# other lists Hiring staff side when we do (vacancy organisations contains an FE college)
VACANCY_SEARCH_SUBJECT_OPTIONS = (SUBJECT_OPTIONS + FURTHER_EDUCATION_SUBJECT_OPTIONS)
  .uniq { |subject, _hint| subject.downcase }
  .sort_by { |subject, _hint| subject.downcase }
