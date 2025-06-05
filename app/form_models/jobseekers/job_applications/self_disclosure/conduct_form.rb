module Jobseekers::JobApplications::SelfDisclosure
  class ConductForm < BaseForm
    attribute :is_known_to_children_services, :boolean
    attribute :has_been_dismissed, :boolean
    attribute :has_been_disciplined, :boolean
    attribute :has_been_disciplined_by_regulatory_body, :boolean

    validates :is_known_to_children_services, inclusion: { in: [true, false] }
    validates :has_been_dismissed, inclusion: { in: [true, false] }
    validates :has_been_disciplined, inclusion: { in: [true, false] }
    validates :has_been_disciplined_by_regulatory_body, inclusion: { in: [true, false] }
  end
end
