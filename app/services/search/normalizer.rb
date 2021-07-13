class Search::Normalizer
  def initialize(value)
    @value = value.downcase
    # drop_stopwords
    synonymize!
  end

  def to_s
    @value
  end

  def synonymize!
    @value.gsub!("mathematics", "maths")
    # One way synonyms: science → (chemistry OR biology OR physics)
  end
end
