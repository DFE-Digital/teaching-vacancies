class Publishers::JobApplication::NotesForm < BaseForm
  attr_accessor :content

  validates :content, presence: true
end
