# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        module Referee
          class HowWouldYouRatePage3 < CommonPage
            set_url "/references/{reference_id}/build/how_would_you_rate_part_3"

            element :outstanding_problem_solving, "label[for='referees-how-would-you-rate-form3-problem-solving-outstanding-field']"
            element :outstanding_general_attitude, "label[for='referees-how-would-you-rate-form3-general-attitude-outstanding-field']"
            element :outstanding_technical_competence, "label[for='referees-how-would-you-rate-form3-technical-competence-outstanding-field']"
            element :outstanding_leadership, "label[for='referees-how-would-you-rate-form3-leadership-outstanding-field']"
          end
        end
      end
    end
  end
end
