# Maps a nested hash to its key structure, replacing leaf values with their class name.
# Used to attach the shape of sensitive payloads (e.g. omniauth auth hashes) to error
# reports without leaking their values.
module HashShape
  def self.of(value)
    case value
    when Hash
      value.to_h { |key, nested| [key, of(nested)] }
    when Array
      value.map { |item| of(item) }
    else
      value.class.name
    end
  end
end
