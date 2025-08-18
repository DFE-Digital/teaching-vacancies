class Publishers::JobApplication::MessagesForm < BaseForm
  attr_accessor :content

  validates :content, presence: true
  validates :content, length: { maximum: 2000 }
end
