# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      class AddDocumentPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/documents/new"
      end
    end
  end
end
