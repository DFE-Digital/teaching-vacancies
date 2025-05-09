class QualificationResult < ApplicationRecord
  belongs_to :qualification

  validates :subject, presence: true
  validates :grade, presence: true

  def duplicate
    # self.class.new(
    #   grade:,
    #   subject:,
    #   awarding_body:,
    # )
    # dup does a shallow copy, but although it "doesn't copy associations" according to the
    # docs, it *does* copy parent associations so we remove these
    dup.tap do |record|
      record.assign_attributes(qualification: nil)
    end
  end

  def empty?
    subject.blank? && grade.blank?
  end
end
