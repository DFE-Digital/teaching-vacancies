class Message < ApplicationRecord
  belongs_to :conversation

  validates :content, presence: true
  validates :sender_id, presence: true

  has_rich_text :content

  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }

  after_create :update_conversation

  def mark_as_read!
    update!(read: true)
  end

  def unread?
    !read?
  end

  private

  def update_conversation
    conversation.with_lock do
      conversation.update(last_message_at: created_at)
    end
  end
end
