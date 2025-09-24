class Conversation < ApplicationRecord
  belongs_to :job_application
  has_many :messages, dependent: :destroy

  scope :inbox, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :for_organisation, lambda { |org_id|
    joins(job_application: :vacancy)
      .merge(Vacancy.in_organisation_ids(org_id))
  }
  scope :with_unread_jobseeker_messages, lambda {
    joins(:messages)
      .where(messages: { type: "JobseekerMessage", read: false })
      .distinct
  }

  scope :ordered_by_unread_and_latest_message, lambda {
    order(has_unread_messages: :desc, last_message_at: :desc)
  }

  def has_unread_messages_for_publishers?
    messages.any? { |msg| msg.is_a?(JobseekerMessage) && msg.unread? }
  end
end
