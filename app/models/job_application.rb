class JobApplication < ApplicationRecord
  enum status: { draft: 0, submitted: 1 }
end
