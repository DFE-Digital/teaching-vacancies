class EmailTemplate < ApplicationRecord
  belongs_to :publisher

  enum :template_type, { rejection: 0 }

  validates :name, :from, :subject, presence: true

  has_rich_text :content
end
