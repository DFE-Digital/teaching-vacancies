class TrainingAndCpd < ApplicationRecord
  self.ignored_columns += %w[jobseeker_profile_id]

  include ApplicationAndProfileAssociatedRecord
end
