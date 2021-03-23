class PublisherPreference < ApplicationRecord
  belongs_to :publisher
  belongs_to :organisation

  has_many :organisation_publisher_preferences, dependent: :destroy
  has_many :organisations, through: :organisation_publisher_preferences

  has_many :local_authority_publisher_schools, dependent: :destroy
  has_many :schools, through: :local_authority_publisher_schools
end
