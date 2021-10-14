base_path = Rails.root.join("config/data")

SUBJECT_OPTIONS = YAML.load_file(base_path.join("subjects.yml"))
