base_path = Rails.root.join('lib/tasks/data')

SUBJECT_OPTIONS = YAML.load_file(base_path.join('subjects.yml'))
