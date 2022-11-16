class SchoolSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :location
  attribute :radius

  def to_h
    attributes.symbolize_keys
  end
end
