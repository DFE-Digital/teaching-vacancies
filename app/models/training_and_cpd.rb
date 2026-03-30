class TrainingAndCpd < ApplicationRecord
  include ApplicationAndProfileAssociatedRecord

  self.ignored_columns += [:jobseeker_profile_id]
end
