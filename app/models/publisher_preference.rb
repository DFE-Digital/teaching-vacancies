# This class stores publisher preferences for organisations.
#
# For Local authorities (LAs) it stores which schools each publisher wants to manage.
# These are stored in local_authority_publisher_schools and accessed via the 'schools' property.
#
# Note: The 'organisation_publisher_preferences' relationship (accessed via 'organisations')
# is deprecated and no longer used. Dashboard filtering is now handled via URL params.
#
class PublisherPreference < ApplicationRecord
  belongs_to :publisher
  belongs_to :organisation

  has_many :organisation_publisher_preferences, dependent: :destroy
  has_many :organisations, through: :organisation_publisher_preferences

  has_many :local_authority_publisher_schools, dependent: :destroy
  has_many :schools, through: :local_authority_publisher_schools
end
