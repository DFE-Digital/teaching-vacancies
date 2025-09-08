module InterviewingRequest
  extend ActiveSupport::Concern

  included do
    # statuses start from 10 to avoid confusion with legacy statuses
    enum :status, { created: 10, requested: 11, received: 12, completed: 13, declined: 14 }
  end
end
