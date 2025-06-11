# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        module Referee
          class ReferenceInformationPage < CommonPage
            BASE = "referees-reference-information-form"

            set_url "/references/{reference_id}/build/reference_information"

            element :under_investigation_yes, "label[for='#{BASE}-under-investigation-true-field']"
            element :warnings_yes, "label[for='#{BASE}-warnings-true-field']"
            element :allegations_yes, "label[for='#{BASE}-allegations-true-field']"
            element :not_fit_to_practice_yes, "label[for='#{BASE}-not-fit-to-practice-true-field']"
            element :able_to_undertake_role_yes, "label[for='#{BASE}-able-to-undertake-role-true-field']"
          end
        end
      end
    end
  end
end
