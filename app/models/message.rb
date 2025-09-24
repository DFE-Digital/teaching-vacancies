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
    conversation.update!(has_unread_messages: false) if conversation.messages.unread.empty?
  end

  def unread?
    !read?
  end

  private

  def update_conversation
    conversation.update(last_message_at: created_at, has_unread_messages: true)
  end
end
