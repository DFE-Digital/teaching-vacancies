# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        module Referee
          class HowWouldYouRatePage1 < CommonPage
            set_url "/references/{reference_id}/build/how_would_you_rate_part_1"

            element :outstanding_punctuality, "label[for='referees-how-would-you-rate-form1-punctuality-outstanding-field']"
            element :outstanding_working_relationships, "label[for='referees-how-would-you-rate-form1-working-relationships-outstanding-field']"
            element :outstanding_customer_care, "label[for='referees-how-would-you-rate-form1-customer-care-outstanding-field']"
            element :outstanding_adapt_to_change, "label[for='referees-how-would-you-rate-form1-adapt-to-change-outstanding-field']"
            element :outstanding_deal_with_conflict, "label[for='referees-how-would-you-rate-form1-deal-with-conflict-outstanding-field']"
            element :outstanding_prioritise_workload, "label[for='referees-how-would-you-rate-form1-prioritise-workload-outstanding-field']"
          end
        end
      end
    end
  end
end
