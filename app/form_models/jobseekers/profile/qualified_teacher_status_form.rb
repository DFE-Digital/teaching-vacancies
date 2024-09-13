class Jobseekers::Profile::QualifiedTeacherStatusForm < BaseForm
  validates :qualified_teacher_status, inclusion: { in: %w[yes no on_track non_teacher] }
  validates :qualified_teacher_status_year, numericality: { less_than_or_equal_to: proc { Time.current.year } }, if: -> { qualified_teacher_status == "yes" }

  def self.fields
    %i[qualified_teacher_status qualified_teacher_status_year]
  end
  attr_accessor(*fields)
end
