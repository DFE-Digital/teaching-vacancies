class Publishers::JobApplication::DeclinedForm < Publishers::JobApplication::TagForm
  attribute :declined_at, :date_or_hash

  validates :declined_at, date: {}, allow_nil: true
end
