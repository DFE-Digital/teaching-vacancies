module CapybaraHelper
  def click_review_page_change_link(section:, row:)
    within("dl", class: "govuk-summary-list", id: section) do
      within("div", class: "govuk-summary-list__row", id: row) do
        click_on I18n.t("buttons.change")
      end
    end
  end

  def within_row_for(text:, element: "label", &)
    element = page.find(element, text: text).find(:xpath, "../..")
    within(element, &)
  end

  def strip_tags(text)
    ActionView::Base.full_sanitizer.sanitize(text)
  end

  # based on this article from 2018:
  # from https://medium.com/eighty-twenty/testing-the-trix-editor-with-capybara-and-minitest-158f895ad15f
  def fill_in_trix_editor(id, with:)
    # find(:xpath, "//trix-editor[@input='#{id}']").click.set(with)
    find("trix-editor##{id}").click.set(with)
  end

  # def find_trix_editor(id)
  #   find(:xpath, "//*[@id='#{id}']", visible: false)
  # end
end
