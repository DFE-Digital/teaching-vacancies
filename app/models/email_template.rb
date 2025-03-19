class EmailTemplate < ApplicationRecord
  belongs_to :publisher

  validates :name, :from, :subject, presence: true

  has_rich_text :content
end
