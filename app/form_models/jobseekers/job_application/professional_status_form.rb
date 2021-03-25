class Jobseekers::JobApplication::ProfessionalStatusForm
  include ActiveModel::Model

  attr_accessor :qualified_teacher_status, :qualified_teacher_status_year, :qualified_teacher_status_details,
                :statutory_induction_complete

  validates :qualified_teacher_status, inclusion: { in: %w[yes no on_track] }
  validates :qualified_teacher_status_year, numericality: { less_than_or_equal_to: proc { Time.current.year } },
                                            if: -> { qualified_teacher_status == "yes" }
  validates :qualified_teacher_status_details, presence: true, if: -> { qualified_teacher_status == "no" }
  validates :statutory_induction_complete, inclusion: { in: %w[yes no] }
end
