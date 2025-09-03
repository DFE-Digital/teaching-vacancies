class Publishers::JobApplication::MessagesForm < BaseForm
  attr_accessor :content

  validates :content, presence: true
end
