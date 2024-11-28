class Jobseekers::JobApplication::BaseForm < BaseForm
  def self.fields
    []
  end

  def self.unstorable_fields
    []
  end

  def self.storable_fields
    fields - unstorable_fields
  end

  class << self
    def load(attrs)
      attrs.symbolize_keys.slice(*fields)
    end
  end
end
