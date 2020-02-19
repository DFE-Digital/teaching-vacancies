class Document < ApplicationRecord
  belongs_to :vacancy
  validates :name, :size, :content_type, :download_url, :google_drive_id, presence: true
end
