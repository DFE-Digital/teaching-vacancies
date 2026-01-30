class Note < ApplicationRecord
  belongs_to :job_application
  belongs_to :publisher
  include Discard::Model

  MAX_WORDS = 100

  validates :content, presence: true
  validates :words_in_content, length: { maximum: MAX_WORDS }

  private

  def words_in_content
    content.scan(/\w+/)
  end
end
