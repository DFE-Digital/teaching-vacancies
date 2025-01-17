class Jobseekers::JobApplication::FollowingReligionForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  class << self
    def storable_fields
      %i[following_religion]
    end
  end

  attribute :following_religion, :boolean

  validates :following_religion, inclusion: { in: [true, false], allow_nil: false }
end
