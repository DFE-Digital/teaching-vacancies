class Jobseekers::JobApplication::EmploymentHistoryForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model
  include ActionView::Helpers::DateHelper

  def self.fields
    %i[employment_history_section_completed unexplained_employment_gaps_present]
  end
  attr_accessor(*fields, :unexplained_employment_gaps)

  validates :employment_history_section_completed, presence: true
  validate :employment_history_gaps_are_explained

  def employment_history_gaps_are_explained
    return unless unexplained_employment_gaps_present == "true" && employment_history_section_completed == "true"

    unexplained_employment_gaps.each_value do |details|
      gap_duration = distance_of_time_in_words(details[:started_on], details[:ended_on] || Time.zone.today)
      errors.add(:base, "You have a gap in your work history (#{gap_duration}).")
    end
  end

  def self.unstorable_fields
    %i[unexplained_employment_gaps unexplained_employment_gaps_present]
  end
end
