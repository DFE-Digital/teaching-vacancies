module Jobseekers::JobApplications::SelfDisclosure
  class BarredListForm < BaseForm
    attribute :is_barred, :boolean
    attribute :has_been_referred, :boolean
  end
end
