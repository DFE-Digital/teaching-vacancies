class QualificationResult < ApplicationRecord
  belongs_to :qualification

  validates :subject, presence: true
  validates :grade, presence: true

  def empty?
    subject.blank? && grade.blank?
  end
end
