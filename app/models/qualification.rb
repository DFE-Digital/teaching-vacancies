class Qualification < ApplicationRecord
  include ApplicationAndProfileAssociatedRecord
  include ActionView::Helpers::SanitizeHelper

  has_many :qualification_results, dependent: :delete_all, autosave: true
  accepts_nested_attributes_for :qualification_results
  has_encrypted :finished_studying_details

  SECONDARY_QUALIFICATIONS = %w[gcse as_level a_level].freeze

  enum :category, { gcse: 0, as_level: 1, a_level: 2, undergraduate: 4, postgraduate: 5, other: 6 }

  before_validation :remove_inapplicable_data, :mark_emptied_qualification_results_for_destruction

  def duplicate
    super.tap do |qualification|
      qualification.assign_attributes(qualification_results: qualification_results.map(&:duplicate))
    end
  end

  def name
    return read_attribute(:name) if read_attribute(:name).present? || other?

    I18n.t("helpers.label.jobseekers_qualifications_category_form.category_options.#{category}")
  end

  def remove_inapplicable_data
    # When `finished_studying` changes, remove answers to questions that no longer apply, so that they aren't displayed
    return if finished_studying.nil?

    if finished_studying?
      self.finished_studying_details = ""
    else
      self.grade = ""
      self.year = nil
      self.month = nil
    end
  end

  def display_attributes
    @display_attributes ||= Enumerator.new do |y|
      display_attributes_list.each do |item|
        next if public_send(item).blank?

        y << item
      end
    end
  end

  def secondary?
    category.in?(SECONDARY_QUALIFICATIONS)
  end

  def award_date
    [Date::MONTHNAMES[month.to_i], year].join(" ").strip
  end

  private

  def display_attributes_list
    return %w[institution award_date] if secondary?

    %w[subject institution].tap do |fields|
      fields.push(*%w[grade award_date]) if finished_studying?
      fields << "awarding_body"
    end
  end

  def mark_emptied_qualification_results_for_destruction
    # The "classic" Rails way of removing associated nested records is setting `_destroy` on the attributes in a form.
    # In the case of qualification results, we want to also allow this by setting all fields to blank, so this marks any
    # completely blank associated qualifications results that would be about to be persisted to be destroyed instead.
    qualification_results.each do |result|
      result.mark_for_destruction if result.empty?
    end
  end
end
