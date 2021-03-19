class OrganisationPublisherPreference < ApplicationRecord
  belongs_to :organisation
  belongs_to :publisher_preference
end
