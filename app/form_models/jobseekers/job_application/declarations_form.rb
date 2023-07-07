class Jobseekers::JobApplication::DeclarationsForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[close_relationships close_relationships_details right_to_work_in_uk]
  end
  attr_accessor(*fields)

  validates :close_relationships, inclusion: { in: %w[yes no] }
  validates :close_relationships_details, presence: true, if: -> { close_relationships == "yes" }
end
