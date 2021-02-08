require "digest/bubblebabble"

##
# Hashes potentially identifiable information. Uses "bubblebabble" algorithm to make the
# resulting SHA hash more human-readable.
class StringAnonymiser
  attr_reader :raw_string

  def initialize(raw_string)
    @raw_string = raw_string.to_s
  end

  def to_s
    raw_string.blank? ? "" : Digest::SHA256.bubblebabble(raw_string)
  end

  alias to_str to_s

  def ==(other)
    other.is_a?(self.class) && raw_string == other.raw_string
  end
end
