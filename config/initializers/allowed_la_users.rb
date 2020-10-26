base_path = Rails.root.join('lib/allowed_organisations')

ALLOWED_LOCAL_AUTHORITIES = YAML.load_file(base_path.join('local_authorities.yml'))
