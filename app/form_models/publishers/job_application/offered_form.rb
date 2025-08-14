class Publishers::JobApplication::OfferedForm < Publishers::JobApplication::TagForm
  attribute :offered_at, :date_or_hash

  validates :offered_at, date: {}, allow_nil: true
end
