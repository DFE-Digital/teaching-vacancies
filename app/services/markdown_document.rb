class MarkdownDocument
  def initialize(section, post_name)
    @section = section
    @post_name = post_name
    parse if exist?
  end

  def title
    @front_matter["title"]
  end

  def category_tags
    @front_matter["category_tags"]&.split(",")&.map(&:strip)
  end

  def date_posted
    @front_matter["date_posted"]
  end

  def meta_description
    @front_matter["meta_description"]
  end

  def content
    @kramdown_document.to_html
  end

  def h2_headings
    @kramdown_document.root
                      .children
                      .select { |element| element.type == :header && element.options[:level] == 2 }
                      .map { |element| element.options[:raw_text] }
  end

  def exist?
    File.exist?(file_path)
  end

  private

  def parse
    @front_matter = FrontMatterParser::Parser.new(:md).call(file_content)
    @kramdown_document = Kramdown::Document.new(@front_matter.content)
  end

  def file_content
    File.read(file_path)
  end

  def file_path
    Rails.root.join("app", "views", "content", @section, "#{@post_name}.md")
  end
end
