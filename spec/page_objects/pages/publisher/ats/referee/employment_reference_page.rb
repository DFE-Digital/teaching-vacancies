# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        module Referee
          class EmploymentReferencePage < CommonPage
            set_url "/references/{reference_id}/build/employment_reference"

            element :currently_employed_no, "label[for='referees-employment-reference-form-currently-employed-false-field']"
            element :reemploy_current_yes, "label[for='referees-employment-reference-form-would-reemploy-current-true-field']"
            element :reemploy_any_yes, "label[for='referees-employment-reference-form-would-reemploy-any-true-field']"

            element :employment_start_day, "#referees_employment_reference_form_employment_start_date_3i"
            element :employment_start_month, "#referees_employment_reference_form_employment_start_date_2i"
            element :employment_start_year, "#referees_employment_reference_form_employment_start_date_1i"

            element :employment_end_day, "#referees_employment_reference_form_employment_end_date_3i"
            element :employment_end_month, "#referees_employment_reference_form_employment_end_date_2i"
            element :employment_end_year, "#referees_employment_reference_form_employment_end_date_1i"
          end
        end
      end
    end
  end
end
