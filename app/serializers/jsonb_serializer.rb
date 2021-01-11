class JsonbSerializer
  def self.dump(value)
    value
  end

  def self.load(value)
    return JSON.parse(value) if value.is_a?(String)

    (value || {}).with_indifferent_access
  end
end
