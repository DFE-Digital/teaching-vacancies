class ReferenceRequest < ApplicationRecord
  validates :token, presence: true

  belongs_to :referee, foreign_key: :reference_id, inverse_of: :reference_request

  validates :reference_id, uniqueness: true

  # marked_as_complete is a seperate field as it can be done
  # even when the request is in the 'created' state as the hiring
  # staff can process references outside the service, but still mark
  # the request as complete when they receive it.
  enum :status, { created: 0, requested: 1, received: 2 }

  validates :status, presence: true

  # expire token after 12 weeks
  scope :active_token, ->(token) { where(token: token, created_at: 12.weeks.ago..) }

  def sent?
    !created?
  end

  has_paper_trail skip: [:token]
end
