module PostsHelper
  def contents_list_items(content)
    safe_join(post_h2_headings(content).map { |element| list_item_anchor(element.options[:raw_text]) })
  end

  private

  def post_h2_headings(document)
    document.root.children.select { |element| element.type == :header && element.options[:level] == 2 }
  end

  def list_item_anchor(text)
    content_tag(:li, link_to(text, "##{text.parameterize}"))
  end
end
