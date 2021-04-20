class Jobseekers::JobApplication::DeclarationsForm
  include ActiveModel::Model

  attr_accessor :close_relationships, :close_relationships_details, :right_to_work_in_uk

  validates :close_relationships, :right_to_work_in_uk, inclusion: { in: %w[yes no] }
  validates :close_relationships_details, presence: true, if: -> { close_relationships == "yes" }
end
