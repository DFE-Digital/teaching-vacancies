# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      class ImportantDatesPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/important_dates"

        element :change_publish_day_field, "#publishers_job_listing_important_dates_form_publish_on_3i"
      end
    end
  end
end
