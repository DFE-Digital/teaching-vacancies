class Note < ApplicationRecord
  belongs_to :job_application
  belongs_to :publisher
  include Discard::Model

  validates :content, presence: true
  validates :content, length: { maximum: 150 }
end
