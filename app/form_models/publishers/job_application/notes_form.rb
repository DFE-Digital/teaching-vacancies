class Publishers::JobApplication::NotesForm < BaseForm
  attr_accessor :content

  validates :content, presence: true
  validates :content, length: { maximum: 150 }
end
