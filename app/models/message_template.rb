class MessageTemplate < ApplicationRecord
  belongs_to :publisher

  enum :template_type, { rejection: 0 }

  validates :name, :template_type, :content, presence: true

  has_rich_text :content
end
