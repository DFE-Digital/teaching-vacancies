class Jobseekers::JobApplication::PersonalStatementForm
  include ActiveModel::Model

  attr_accessor :personal_statement

  validates :personal_statement, presence: true
end
