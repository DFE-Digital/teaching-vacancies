module Jobseekers
  class EmploymentForm
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Attributes

    attr_accessor :organisation, :job_title, :subjects, :main_duties, :reason_for_leaving

    attribute :is_current_role, :boolean
    attribute :started_on, :date
    attribute :ended_on, :date

    # KSIE dictates that we need a reason_for_leaving even for current role
    validates :organisation, :job_title, :main_duties, :reason_for_leaving, presence: true
    validates :started_on, date: { before: :today }

    validates :ended_on, date: { before: :today, on_or_after: :started_on }, unless: -> { is_current_role }
    validates :ended_on, absence: true, if: -> { is_current_role }
  end
end
