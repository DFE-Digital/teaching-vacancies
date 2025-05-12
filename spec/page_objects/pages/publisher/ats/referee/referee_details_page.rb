# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        module Referee
          class RefereeDetailsPage < CommonPage
            set_url "/references/{reference_id}/build/referee_details"

            element :complete_and_accurate_checkbox, "label[for='referees-referee-details-form-complete-and-accurate-1-field']"
          end
        end
      end
    end
  end
end
