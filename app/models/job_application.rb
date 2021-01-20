class JobApplication < ApplicationRecord
  enum status: { draft: 0, submitted: 1 }

  belongs_to :jobseeker
  belongs_to :vacancy
end
