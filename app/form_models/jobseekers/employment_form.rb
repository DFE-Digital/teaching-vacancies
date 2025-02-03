module Jobseekers
  class EmploymentForm
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Attributes

    attr_accessor :organisation, :job_title, :subjects, :main_duties, :reason_for_leaving

    attribute :current_role, :boolean
    attribute :started_on, :date
    attribute :ended_on, :date

    validates :organisation, :job_title, :main_duties, presence: true
    validates :reason_for_leaving, presence: true, unless: -> { current_role }
    validates :started_on, date: { before: :today }

    validates :ended_on, date: { before: :today, on_or_after: :started_on }, unless: -> { current_role }
  end
end
