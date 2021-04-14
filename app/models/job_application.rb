class JobApplication < ApplicationRecord
  before_save :update_status_timestamp, if: :will_save_change_to_status?

  extend ArrayEnum

  array_enum completed_steps: {
    personal_details: 0,
    professional_status: 1,
    qualifications: 2,
    employment_history: 3,
    personal_statement: 4,
    references: 5,
    equal_opportunities: 6,
    ask_for_support: 7,
    declarations: 8,
  }

  array_enum in_progress_steps: {
    personal_details: 0,
    professional_status: 1,
    qualifications: 2,
    employment_history: 3,
    personal_statement: 4,
    references: 5,
    equal_opportunities: 6,
    ask_for_support: 7,
    declarations: 8,
  }

  # If you want to add a status, be sure to add a `status_at` column to the `job_applications` table
  enum status: { draft: 0, submitted: 1, shortlisted: 2, unsuccessful: 3, withdrawn: 4 }, _default: 0

  belongs_to :jobseeker
  belongs_to :vacancy

  has_many :qualifications, dependent: :destroy
  has_many :employments, dependent: :destroy
  has_many :references, dependent: :destroy

  scope :submitted_yesterday, -> { submitted.where("DATE(submitted_at) = ?", Date.yesterday) }

  def qualification_groups
    # Untested method

    # When qualifications match on name, institution, and year, group/merge them into single objects for displaying.
    # Note that the labels on the summary vary per type.
    groups = qualifications.group_by { |qual| [qual.name, qual.institution, qual.year] }
    # groups.transform_values! { |group| group.sort_by { |qual| qual.subject } }
    groups.values.sort_by { |group| group.min_by(&:created_at).created_at }
  end

  private

  def update_status_timestamp
    self["#{status}_at"] = Time.current
  end
end
