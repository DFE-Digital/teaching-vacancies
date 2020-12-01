class SavedJob < ApplicationRecord
  belongs_to :jobseeker
  belongs_to :vacancy
end
