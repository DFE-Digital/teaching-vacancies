class QualificationResult < ApplicationRecord
  belongs_to :qualification

  validates :subject, presence: true
  validates :grade, presence: true

  def duplicate
    self.class.new(
      grade:,
      subject:,
    )
  end

  def empty?
    subject.blank? && grade.blank?
  end
end
