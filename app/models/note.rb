class Note < ApplicationRecord
  belongs_to :job_application
  belongs_to :publisher
  include Discard::Model

  validates :content, presence: true
  # from https://guides.rubyonrails.org/v4.1/active_record_validations.html
  validates :content, length: {
    maximum: 150,
    tokenizer: ->(str) { str.scan(/\w+/) },
  }
end
