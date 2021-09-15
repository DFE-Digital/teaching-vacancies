class Jobseekers::JobApplication::PersonalStatementForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[personal_statement]
  end
  attr_accessor(*fields)

  validates :personal_statement, presence: true
end
