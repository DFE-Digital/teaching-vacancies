# Suggests a corrected keyword by comparing each word to the words used in live vacancy titles and subjects.
class Search::KeywordCorrection
  MIN_WORD_LENGTH = 4
  MIN_SIMILARITY = 0.4

  def initialize(keyword)
    @words = keyword.to_s.downcase.split
  end

  def call
    corrected = @words.map { |word| correct(word) }
    corrected.join(" ") if corrected != @words
  end

  private

  def correct(word)
    return word if word.length < MIN_WORD_LENGTH

    best_match(word) || word
  end

  def best_match(word)
    sql = Vacancy.sanitize_sql_array([
      "SELECT vocabulary.word FROM (#{vocabulary_sql}) vocabulary " \
      "WHERE similarity(vocabulary.word, ?) >= ? " \
      "ORDER BY similarity(vocabulary.word, ?) DESC, vocabulary.word LIMIT 1",
      word,
      MIN_SIMILARITY,
      word,
    ])
    Vacancy.connection.select_value(sql)
  end

  def vocabulary_sql
    @vocabulary_sql ||= PublishedVacancy.live.reorder(nil).select(
      Arel.sql(
        "DISTINCT lower(regexp_split_to_table(" \
        "concat_ws(' ', vacancies.job_title, array_to_string(vacancies.subjects, ' ')), '[^[:alnum:]]+')) AS word",
      ),
    ).to_sql
  end
end
