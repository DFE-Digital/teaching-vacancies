class Jobseekers::JobApplication::FollowingReligionForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[following_religion]
  end
  attr_accessor(*fields)

  validates :following_religion, inclusion: { in: %w[yes no] }
end
