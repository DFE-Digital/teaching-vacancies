module CapybaraHelper
  def click_review_page_change_link(section:, row:)
    within("dl", class: "govuk-summary-list", id: section) do
      within("div", class: "govuk-summary-list__row", id: row) do
        find(".govuk-link", match: :first).click
      end
    end
  end

  # def click_review_page_change_link(section:, match: 0)
  #   within("dl", class: "govuk-summary-list", id: section) do
  #     all(".govuk-link")[match].click
  #   end
  # end

  def within_row_for(text:, element: "label", &block)
    element = page.find(element, text: text).find(:xpath, "../..")
    within(element, &block)
  end

  def strip_tags(text)
    ActionView::Base.full_sanitizer.sanitize(text)
  end
end
