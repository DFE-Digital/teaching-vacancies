class FailedImportedVacancy < ActiveRecord::Base
  validates :source, presence: true
end
