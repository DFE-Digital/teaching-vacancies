class Qualification < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper

  belongs_to :job_application
  has_many :qualification_results, dependent: :delete_all, autosave: true
  accepts_nested_attributes_for :qualification_results
  lockbox_encrypts :finished_studying_details

  SECONDARY_QUALIFICATIONS = %w[gcse as_level a_level other_secondary].freeze

  enum category: { gcse: 0, as_level: 1, a_level: 2, other_secondary: 3, undergraduate: 4, postgraduate: 5, other: 6 }

  before_validation :remove_inapplicable_data, :mark_emptied_qualification_results_for_destruction

  def name
    return read_attribute(:name) if read_attribute(:name).present? || other? || other_secondary?

    I18n.t("helpers.label.jobseekers_job_application_details_qualifications_category_form.category_options.#{category}")
  end

  def remove_inapplicable_data
    # When `finished_studying` changes, remove answers to questions that no longer apply, so that they aren't displayed
    return if finished_studying.nil?

    if finished_studying?
      self.finished_studying_details = ""
    else
      self.grade = ""
      self.year = nil
    end
  end

  def display_attributes
    if secondary?
      %w[institution year]
    elsif finished_studying?
      %w[subject institution grade year]
    else
      %w[subject institution]
    end
  end

  def secondary?
    category.in?(SECONDARY_QUALIFICATIONS)
  end

  private

  def mark_emptied_qualification_results_for_destruction
    # The "classic" Rails way of removing associated nested records is setting `_destroy` on the attributes in a form.
    # In the case of qualification results, we want to also allow this by setting all fields to blank, so this marks any
    # completely blank associated qualifications results that would be about to be persisted to be destroyed instead.
    qualification_results.each do |result|
      result.mark_for_destruction if result.empty?
    end
  end
end
