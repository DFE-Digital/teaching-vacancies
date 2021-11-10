Rails.application.configure do
  config_dir = Rails.root.join("config/search")

  synonyms = YAML.load_file(config_dir.join("synonyms.yml"))
  oneway_synonyms = YAML.load_file(config_dir.join("oneway_synonyms.yml"))

  # All terms in each of our synonym dictionaries in one convenient array
  # The order is important so when we scan a search query for phrases, we "catch" the longest
  # ones first in case the same query also contains shorter terms.
  synonym_triggers = synonyms
    .flatten
    .uniq
    .sort_by { |phrase| phrase.count(" ") }
    .reverse
  oneway_synonym_triggers = oneway_synonyms
    .keys
    .uniq
    .sort_by { |phrase| phrase.count(" ") }
    .reverse

  config.x.search.synonyms = synonyms
  config.x.search.synonym_triggers = synonym_triggers

  config.x.search.oneway_synonyms = oneway_synonyms
  config.x.search.oneway_synonym_triggers = oneway_synonym_triggers
end
