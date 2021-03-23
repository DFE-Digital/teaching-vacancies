class LocalAuthorityPublisherSchool < ApplicationRecord
  belongs_to :publisher_preference
  belongs_to :school
end
