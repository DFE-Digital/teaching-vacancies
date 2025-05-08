# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      class VacancyPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}"

        element :change_additional_documents_link, "#include_additional_documents a"
      end
    end
  end
end
