class Jobseekers::JobApplication::Details::Qualifications::CategoryForm
  include ActiveModel::Model

  attr_accessor :category

  validates :category, inclusion: { in: Qualification.categories.keys }
end
