class Publishers::JobApplication::OfferDateForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :date_of_birth, :date_or_hash
end
