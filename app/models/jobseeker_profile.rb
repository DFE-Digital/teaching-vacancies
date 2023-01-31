class JobseekerProfile < ApplicationRecord
  belongs_to :jobseeker
  has_one :personal_details
end
