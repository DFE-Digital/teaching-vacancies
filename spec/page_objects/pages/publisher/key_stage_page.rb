module PageObjects
  module Pages
    module Publisher
      class KeyStagePage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/key_stages"

        def fill_in_and_submit_form(key_stages)
          key_stages.each do |key_stage|
            check I18n.t("helpers.label.publishers_job_listing_key_stages_form.key_stages_options.#{key_stage}")
          end
          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
