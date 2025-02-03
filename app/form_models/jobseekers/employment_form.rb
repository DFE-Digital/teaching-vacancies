module Jobseekers
  class EmploymentForm
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include DateAttributeAssignment
    include ActiveModel::Attributes

    attr_accessor :organisation, :job_title, :subjects, :main_duties, :reason_for_leaving

    attr_reader :started_on, :ended_on

    attribute :current_role, :boolean

    validates :organisation, :job_title, :main_duties, presence: true
    validates :reason_for_leaving, presence: true, unless: -> { current_role }
    validates :started_on, date: { before: :today }

    validates :ended_on, date: { before: :today, on_or_after: :started_on }, unless: -> { current_role }

    def started_on=(value)
      @started_on = date_from_multiparameter_hash(value)
    end

    def ended_on=(value)
      @ended_on = date_from_multiparameter_hash(value)
    end
  end
end
