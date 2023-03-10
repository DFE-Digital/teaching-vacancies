class Jobseekers::Profile::QualificationsForm
  include ActiveModel::Model
  validates :category, presence: true

  def self.fields
    %i[category]
  end
  attr_accessor(*fields)
end
