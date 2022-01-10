module CapybaraHelper
  def click_header_link(text)
    find(".review-component__section__heading__title", text:).find("a", text: "Change").click
  end

  def within_row_for(text:, element: "label", &block)
    element = page.find(element, text:).find(:xpath, "../..")
    within(element, &block)
  end

  def strip_tags(text)
    ActionView::Base.full_sanitizer.sanitize(text)
  end
end
