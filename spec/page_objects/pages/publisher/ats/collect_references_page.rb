# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      module Ats
        class CollectReferencesPage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_application_batches/{job_application_batch_id}/references_and_self_disclosure/collect_references"

          element :btn_save_and_continue, 'button[type="submit"].govuk-button', text: I18n.t("buttons.save_and_continue")
          element :radio_yes, "label[for='publishers-job-application-collect-references-form-collect-references-true-field']"
          element :radio_no, "label[for='publishers-job-application-collect-references-form-collect-references-false-field']"

          def answer_yes
            radio_yes.click
            btn_save_and_continue.click
          end

          def answer_no
            radio_no.click
            btn_save_and_continue.click
          end
        end
      end
    end
  end
end
