class Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  include ActiveModel::Model, Jobseekers::QualificationsHelper

  attr_accessor :category, :finished_studying, :finished_studying_details, :name, :institution, :year

  def initialize(attributes = {})
    @attributes = attributes
    subject_and_grade_attributes.each { |attribute| self.class.send(:attr_accessor, attribute) }

    assign_attributes(attributes) if attributes
  end

  def row_count
    @row_count ||= subject_and_grade_attributes.map { |attr| param_key_digit(attr) }.uniq.count
  end

  validates :category, presence: true
  validates :finished_studying_details, presence: true, if: -> { finished_studying == "false" }
  validates :year, presence: true, if: -> { finished_studying == "true" }
  validates :year, format: { with: /\A\d{4}\z/.freeze }, if: -> { year.present? }

  private

  def subject_and_grade_attributes
    @subject_and_grade_attributes ||=
      @attributes.keys.select { |key| /\A(subject|grade)\d+\z/.match?(key.to_s) }.concat(%w[subject1 grade1]).uniq
  end
end
