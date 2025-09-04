class Message < ApplicationRecord
  belongs_to :conversation

  validates :content, presence: true
  validates :sender_id, presence: true

  has_rich_text :content
end
