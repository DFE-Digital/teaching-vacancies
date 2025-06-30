# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        module Referee
          class HowWouldYouRatePage2 < CommonPage
            set_url "/references/{reference_id}/build/how_would_you_rate_part_2"

            element :outstanding_deal_with_conflict, "label[for='referees-how-would-you-rate-form2-deal-with-conflict-outstanding-field']"
            element :outstanding_prioritise_workload, "label[for='referees-how-would-you-rate-form2-prioritise-workload-outstanding-field']"
            element :outstanding_team_working, "label[for='referees-how-would-you-rate-form2-team-working-outstanding-field']"
            element :outstanding_communication, "label[for='referees-how-would-you-rate-form2-communication-outstanding-field']"
          end
        end
      end
    end
  end
end
