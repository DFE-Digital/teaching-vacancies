class Message < ApplicationRecord
  has_rich_text :content
  belongs_to :conversation
  belongs_to :sender, polymorphic: true

  validates :content, presence: true
end