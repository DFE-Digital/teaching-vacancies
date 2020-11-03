module ApplicationHelpers
  def script_tag_content(wrapper_class: "")
    page.all("script#{wrapper_class}", visible: false).first.native.text.strip
  end
end
