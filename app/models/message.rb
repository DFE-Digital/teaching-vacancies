class Message < ApplicationRecord
  belongs_to :conversation

  validates :content, presence: true
  validates :sender_id, presence: true

  has_rich_text :content

  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }

  def mark_as_read!
    update!(read: true)
  end

  def unread?
    !read?
  end
end
