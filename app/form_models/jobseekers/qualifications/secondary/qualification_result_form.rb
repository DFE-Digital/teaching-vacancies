class Jobseekers::Qualifications::Secondary::QualificationResultForm
  include ActiveModel::Model

  attr_accessor :id, :subject, :grade

  validates :subject, presence: true
  validates :grade, presence: true

  def empty?
    subject.blank? && grade.blank?
  end

  def persisted?
    # Needed so that `fields_for` knows to include the hidden ID field when re-rendering the form after submission
    # if validation fails (it is skipped if `persisted?` is false, which is the default in ActiveModel)
    id.present?
  end
end
