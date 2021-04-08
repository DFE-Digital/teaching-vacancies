class Qualification < ApplicationRecord
  belongs_to :job_application

  enum category: { gcse: 0, as_level: 1, a_level: 2, other_secondary: 3, undergraduate: 4, postgraduate: 5, other: 6 }

  before_validation :remove_irrelevant_data

  def name
    return read_attribute(:name) if read_attribute(:name).present? || other? || other_secondary?

    I18n.t("helpers.label.jobseekers_job_application_details_qualifications_category_form.category_options.#{category}")
  end

  def remove_irrelevant_data
    return if finished_studying.nil?

    if finished_studying?
      self.finished_studying_details = ""
    else
      self.grade = ""
      self.year = nil
    end
  end
end
