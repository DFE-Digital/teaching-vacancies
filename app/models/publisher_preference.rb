class PublisherPreference < ApplicationRecord
  belongs_to :publisher
  belongs_to :organisation

  has_many :organisation_publisher_preferences, dependent: :destroy
  has_many :organisations, through: :organisation_publisher_preferences
end
