# This class serves 2 distinct purposes:
#
# 1. For Local authorities (LAs) it stores the 'filter' for which schools
# each publisher wants to manage - these are stored in local_authority_publisher_schools
# and mostly accessed via the 'schools' property
#
# 2. For all organisations, the 'organisation_publisher_preferences' relationship
# ()mostly accessed via organisations)
# is a database-backed organisation filter - this allows the filter to be preserved
# between pages when nvaigating between different tabs. The filters are managed via
# the PublisherPreferencesController, often by removing and adding single filters
# and then redisplaying publisher/vacancies#index page
#
class PublisherPreference < ApplicationRecord
  belongs_to :publisher
  belongs_to :organisation

  has_many :organisation_publisher_preferences, dependent: :destroy
  has_many :organisations, through: :organisation_publisher_preferences

  has_many :local_authority_publisher_schools, dependent: :destroy
  has_many :schools, through: :local_authority_publisher_schools
end
