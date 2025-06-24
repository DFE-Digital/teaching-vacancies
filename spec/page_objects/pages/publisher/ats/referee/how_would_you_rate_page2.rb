# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        module Referee
          class HowWouldYouRatePage2 < CommonPage
            set_url "/references/{reference_id}/build/how_would_you_rate_part_2"

            element :outstanding_team_working, "label[for='referees-how-would-you-rate-form2-team-working-outstanding-field']"
            element :outstanding_communication, "label[for='referees-how-would-you-rate-form2-communication-outstanding-field']"
            element :outstanding_problem_solving, "label[for='referees-how-would-you-rate-form2-problem-solving-outstanding-field']"
            element :outstanding_general_attitude, "label[for='referees-how-would-you-rate-form2-general-attitude-outstanding-field']"
            element :outstanding_technical_competence, "label[for='referees-how-would-you-rate-form2-technical-competence-outstanding-field']"
            element :outstanding_leadership, "label[for='referees-how-would-you-rate-form2-leadership-outstanding-field']"
          end
        end
      end
    end
  end
end
