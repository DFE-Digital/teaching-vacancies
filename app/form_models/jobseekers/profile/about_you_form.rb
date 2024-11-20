class Jobseekers::Profile::AboutYouForm < BaseForm
  validates :about_you, presence: true
  validate :about_you_does_not_exceed_maximum_words

  def self.fields
    %i[about_you]
  end
  attr_accessor(*fields)

  def about_you_does_not_exceed_maximum_words
    errors.add(:about_you, :length) if number_of_words_exceeds_permitted_length?(1000, about_you)
  end
end
