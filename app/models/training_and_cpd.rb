class TrainingAndCpd < ApplicationRecord
  self.ignored_columns += ["jobseeker_profile_id"]

  include ApplicationAndProfileAssociatedRecord
end
