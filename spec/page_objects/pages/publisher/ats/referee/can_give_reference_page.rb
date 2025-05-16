# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        module Referee
          class CanGiveReferencePage < CommonPage
            set_url "/references/{reference_id}/build/can_give?token={token}"
          end
        end
      end
    end
  end
end
