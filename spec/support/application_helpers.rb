module ApplicationHelpers
  def script_tag_content(wrapper_class: "")
    page.first("script#{wrapper_class}", visible: false).native.text.strip
  end
end
