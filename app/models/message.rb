class Message < ApplicationRecord
  has_rich_text :content
  belongs_to :job_application
  belongs_to :sender, polymorphic: true

  validates :content, presence: true
end