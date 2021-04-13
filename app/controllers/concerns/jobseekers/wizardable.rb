module Jobseekers::Wizardable
  def personal_details_fields
    %i[city first_name last_name national_insurance_number phone_number previous_names postcode street_address teacher_reference_number]
  end

  def professional_status_fields
    %i[qualified_teacher_status qualified_teacher_status_year qualified_teacher_status_details statutory_induction_complete]
  end

  def qualifications_fields
    []
  end

  def employment_history_fields
    %i[gaps_in_employment gaps_in_employment_details]
  end

  def personal_statement_fields
    %i[personal_statement]
  end

  def references_fields
    []
  end

  def equal_opportunities_fields
    %i[disability gender gender_description orientation orientation_description ethnicity ethnicity_description religion religion_description]
  end

  def ask_for_support_fields
    %i[support_needed support_needed_details]
  end

  def declarations_fields
    %i[banned_or_disqualified close_relationships close_relationships_details right_to_work_in_uk]
  end
end
