class Jobseekers::JobApplication::QualificationsForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[qualifications_section_completed]
  end
  attr_accessor(*fields)

  validates :qualifications_section_completed, presence: true
end
