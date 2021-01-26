class Jobseekers::JobApplication::AskForSupportForm
  include ActiveModel::Model

  attr_accessor :support_needed, :support_details

  validates :support_needed, inclusion: { in: %w[yes no] }
  validates :support_details, presence: true, if: -> { support_needed == "yes" }

  def initialize(params = {})
    @support_needed = params[:support_needed]
    @support_details = support_needed == "yes" ? params[:support_details] : nil
  end
end
