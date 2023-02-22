class Jobseekers::Qualifications::CategoryForm < BaseForm
  attr_accessor :category, :name

  validates :category, inclusion: { in: Qualification.categories.keys }
end
