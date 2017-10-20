module ApplicationHelpers
  def script_tag_content(wrapper_class: '')
    page.all("#{wrapper_class} script", visible: false).first.native.text.strip
  end
end
