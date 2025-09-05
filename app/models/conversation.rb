class Conversation < ApplicationRecord
  belongs_to :job_application
  has_many :messages, dependent: :destroy

  scope :inbox, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }

  def self.default_title_for(job_application)
    "Regarding application: #{job_application.vacancy.job_title}"
  end

  def has_unread_messages_for_publishers?
    messages.any? { |msg| msg.is_a?(JobseekerMessage) && msg.unread? }
  end
end
