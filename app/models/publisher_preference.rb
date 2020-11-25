class PublisherPreference < ApplicationRecord
  belongs_to :publisher
  belongs_to :school_group, optional: true
end
