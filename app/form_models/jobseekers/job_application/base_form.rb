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
end
