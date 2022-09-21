module CapybaraHelper
  def click_review_page_change_link(section:)
    within("dl", class: "govuk-summary-list", id: section) do
      find(".govuk-link", match: :first).click
    end
  end

  def within_row_for(text:, element: "label", &block)
    element = page.find(element, text: text).find(:xpath, "../..")
    within(element, &block)
  end

  def strip_tags(text)
    ActionView::Base.full_sanitizer.sanitize(text)
  end
end
