module CapybaraHelper
  def click_link_in_container_with_text(text)
    find(:xpath, "//tr[td[contains(text(), '#{text}')]]").find('td.cya-change a').click
  end

  def within_row_for(element: 'label', text:, &block)
    element = page.find(element, text: text).find(:xpath, '..')
    within(element, &block)
  end
end
