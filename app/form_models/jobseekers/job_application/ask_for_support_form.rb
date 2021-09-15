class Jobseekers::JobApplication::AskForSupportForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[support_needed support_needed_details]
  end
  attr_accessor(*fields)

  validates :support_needed, inclusion: { in: %w[yes no] }
  validates :support_needed_details, presence: true, if: -> { support_needed == "yes" }
end
