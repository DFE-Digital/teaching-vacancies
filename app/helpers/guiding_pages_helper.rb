module GuidingPagesHelper
  ALWAYS_CAPITALIZE_WORDS = ["england"].freeze

  def format_title(subcategory)
    words = subcategory.downcase.split("-")
    words.map!.with_index do |word, index|
      word.capitalize! if index.zero? || ALWAYS_CAPITALIZE_WORDS.include?(word)
      word
    end
    words.join(" ")
  end
end
