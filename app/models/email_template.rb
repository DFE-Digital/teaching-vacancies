class EmailTemplate < ApplicationRecord
  belongs_to :publisher

  enum :template_type, { rejection: 0 }

  validates :name, :from, :subject, :template_type, presence: true

  has_rich_text :content
end
