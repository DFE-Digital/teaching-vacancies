class Jobseekers::Qualifications::QualificationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :category, :finished_studying_details, :name, :institution, :year, :month, :awarding_body

  attribute :finished_studying, :boolean

  validates :category, presence: true
  validates :finished_studying_details, presence: true, if: -> { finished_studying == false }
  validates :year, numericality: { less_than_or_equal_to: proc { Time.current.year } },
                   if: -> { finished_studying }
  validates :month, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 12 },
                    allow_blank: true,
                    if: -> { finished_studying }

  def secondary?
    false
  end
end
