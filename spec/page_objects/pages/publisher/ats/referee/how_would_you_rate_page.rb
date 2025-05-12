# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        module Referee
          class HowWouldYouRatePage < CommonPage
            set_url "/references/{reference_id}/build/how_would_you_rate"

            element :outstanding_punctuality, "label[for='referees-how-would-you-rate-form-punctuality-outstanding-field']"
            element :outstanding_working_relationships, "label[for='referees-how-would-you-rate-form-working-relationships-outstanding-field']"
            element :outstanding_customer_care, "label[for='referees-how-would-you-rate-form-customer-care-outstanding-field']"
            element :outstanding_adapt_to_change, "label[for='referees-how-would-you-rate-form-adapt-to-change-outstanding-field']"
            element :outstanding_deal_with_conflict, "label[for='referees-how-would-you-rate-form-deal-with-conflict-outstanding-field']"
            element :outstanding_prioritise_workload, "label[for='referees-how-would-you-rate-form-prioritise-workload-outstanding-field']"
            element :outstanding_team_working, "label[for='referees-how-would-you-rate-form-team-working-outstanding-field']"
            element :outstanding_communication, "label[for='referees-how-would-you-rate-form-communication-outstanding-field']"
            element :outstanding_problem_solving, "label[for='referees-how-would-you-rate-form-problem-solving-outstanding-field']"
            element :outstanding_general_attitude, "label[for='referees-how-would-you-rate-form-general-attitude-outstanding-field']"
            element :outstanding_technical_competence, "label[for='referees-how-would-you-rate-form-technical-competence-outstanding-field']"
            element :outstanding_leadership, "label[for='referees-how-would-you-rate-form-leadership-outstanding-field']"
          end
        end
      end
    end
  end
end
