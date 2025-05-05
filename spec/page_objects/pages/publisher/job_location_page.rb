module PageObjects
  module Pages
    module Publisher
      class JobLocationPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/job_location"

        element :continue_button, "input[value='#{I18n.t('buttons.continue')}']"

        def fill_in_and_submit_form(vacancy)
          vacancy.organisations.each do |organisation|
            check(organisation.school? ? organisation.name : I18n.t("organisations.job_location_heading.central_office"))
          end
          click_on I18n.t("buttons.continue")
        end

        def continue
          continue_button.click
        end
      end
    end
  end
end
