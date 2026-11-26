# Builds links to searches that would return results, for a vacancy search that returned none.
# The location is only ever widened, never removed.
class Search::NoResultsSuggestionsBuilder
  MAX_SUGGESTIONS = 4

  # Filters that may be offered for removal. Visa sponsorship and organisation type are deliberately absent.
  RELAXABLE_FILTERS = {
    phases: %i[phases],
    working_patterns: %i[working_patterns],
    job_roles: %i[teaching_job_roles support_job_roles],
    subjects: %i[subjects],
    quick_apply: %i[quick_apply],
  }.freeze

  BROWSE_CRITERIA = {
    teaching: { teaching_job_roles: Vacancy::TEACHING_JOB_ROLES },
    support: { support_job_roles: Vacancy::SUPPORT_JOB_ROLES },
  }.freeze

  Suggestion = Data.define(:type, :criteria, :count, :options)
  Result = Data.define(:spelling, :suggestions, :browse)

  def self.call(search)
    return if search.organisation_slug.present? || !search.active_criteria? || search.total_count.positive?

    new(search).call
  end

  def initialize(search)
    @search = search
    @criteria = search.active_criteria
  end

  def call
    suggestions = relaxations
    Result.new(spelling: spelling, suggestions: suggestions, browse: suggestions.empty? ? browse : [])
  end

  private

  attr_reader :search, :criteria

  def spelling
    corrected = Search::KeywordCorrection.new(search.keyword).call
    return if corrected.blank?

    corrected_criteria = criteria.merge(keyword: corrected)
    count = count_for(corrected_criteria)
    Suggestion.new(type: :spelling, criteria: corrected_criteria, count: count, options: { keyword: corrected }) if count.positive?
  end

  def relaxations
    ranked = [radius_suggestion, *filter_suggestions, *keyword_suggestions].compact
    ranked.each_with_index.sort_by { |suggestion, index| [rank(suggestion), -suggestion.count, index] }
          .map(&:first).first(MAX_SUGGESTIONS)
  end

  def rank(suggestion)
    { radius: 0, filter: 1, keyword: 2 }.fetch(suggestion.type)
  end

  def radius_suggestion
    radius, count = Search::WiderSuggestionsBuilder.call(search)&.first
    return unless radius

    Suggestion.new(type: :radius, criteria: criteria.merge(radius: radius), count: count, options: { radius: radius, location: search.location })
  end

  def filter_suggestions
    RELAXABLE_FILTERS.filter_map do |filter, keys|
      next unless criteria.keys.intersect?(keys)

      relaxed = criteria.except(*keys)
      count = count_for(relaxed)
      Suggestion.new(type: :filter, criteria: relaxed, count: count, options: { filter: filter }) if count.positive?
    end
  end

  def keyword_suggestions
    words = search.keyword.to_s.split.uniq
    return [] if words.size < 2

    words.filter_map do |word|
      relaxed = criteria.merge(keyword: (words - [word]).join(" "))
      count = count_for(relaxed)
      Suggestion.new(type: :keyword, criteria: relaxed, count: count, options: { word: word }) if count.positive?
    end
  end

  def browse
    BROWSE_CRITERIA.filter_map do |type, browse_criteria|
      count = count_for(browse_criteria)
      Suggestion.new(type: type, criteria: browse_criteria, count: count, options: {}) if count.positive?
    end
  end

  def count_for(search_criteria)
    Search::VacancySearch.new(search_criteria).total_count
  end
end
