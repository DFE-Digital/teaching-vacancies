module ComponentHelpers
  def render_inline(component, **_kwargs, &_block)
    return super if ENV["CI"] == "true"

    test_html_directory = Rails.root.join(component.view_component_path, component.class.name.underscore, "test_html")
    variant_name, *group_directory_names = self.class.parent_groups.map { |g| g.description.gsub(/\W/, "_") }
    context_directory = test_html_directory.join(*group_directory_names.reverse)
    context_directory.mkpath

    variant_path = context_directory.join("#{variant_name}.test.html")

    super.tap do |html|
      File.open(variant_path, "w") { |f| f.write(html.to_xhtml.chomp, "\n") }
    end
  end
end
