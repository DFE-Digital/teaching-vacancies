class NativeJobApplication < JobApplication
  before_save :anonymise_report, if: :will_save_change_to_status?
  before_save :reset_support_needed_details

  array_enum completed_steps: {
    personal_details: 0,
    professional_status: 1,
    qualifications: 2,
    training_and_cpds: 9,
    professional_body_memberships: 12,
    employment_history: 3,
    personal_statement: 4,
    catholic: 10,
    non_catholic: 11,
    referees: 5,
    equal_opportunities: 6,
    ask_for_support: 7,
    declarations: 8,
  }

  array_enum imported_steps: {
    personal_details: 0,
    professional_status: 1,
    qualifications: 2,
    training_and_cpds: 9,
    professional_body_memberships: 12,
    employment_history: 3,
    personal_statement: 4,
    catholic: 10,
    non_catholic: 11,
    referees: 5,
    equal_opportunities: 6,
    ask_for_support: 7,
    declarations: 8,
  }

  array_enum in_progress_steps: {
    qualifications: 0,
    employment_history: 1,
    personal_details: 2,
    professional_status: 3,
    training_and_cpds: 4,
    professional_body_memberships: 12,
    referees: 5,
    equal_opportunities: 6,
    personal_statement: 7,
    declarations: 8,
    ask_for_support: 9,
    catholic: 10,
    non_catholic: 11,
  }

  has_many :qualifications, foreign_key: :job_application_id, dependent: :destroy
  has_many :employments, foreign_key: :job_application_id, dependent: :destroy
  has_many :referees, foreign_key: :job_application_id, dependent: :destroy
  has_many :training_and_cpds, foreign_key: :job_application_id, dependent: :destroy
  has_many :professional_body_memberships, foreign_key: :job_application_id, dependent: :destroy

  def unexplained_employment_gaps
    @unexplained_employment_gaps ||= Jobseekers::JobApplications::EmploymentGapFinder.new(self).significant_gaps
  end

  private

  def anonymise_report
    return unless status == "submitted"

    fill_in_report
    reset_equal_opportunities_attributes
  end

  def fill_in_report
    report = vacancy.equal_opportunities_report || vacancy.build_equal_opportunities_report
    Jobseekers::JobApplication::EqualOpportunitiesForm.storable_fields.each do |attr|
      attr_value = public_send(attr)
      next if attr_value.blank?

      if attr.ends_with?("_description")
        attr_name = attr.to_s.split("_").first
        report.public_send(:"#{attr_name}_other_descriptions") << attr_value
      else
        report.increment("#{attr}_#{attr_value}")
      end
    end
    report.increment(:total_submissions)
    report.save!
  end

  def reset_equal_opportunities_attributes
    Jobseekers::JobApplication::EqualOpportunitiesForm.storable_fields.each { |attr| self[attr] = "" }
  end

  def reset_support_needed_details
    self[:support_needed_details] = "" unless is_support_needed?
  end
end
