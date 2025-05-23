module Jobseekers::JobApplications::SelfDisclosure
  class BarredListForm < BaseForm
    attribute :is_barred, :boolean
    attribute :has_been_referred, :boolean

    validates :is_barred, inclusion: { in: [true, false] }
    validates :has_been_referred, inclusion: { in: [true, false] }
  end
end
