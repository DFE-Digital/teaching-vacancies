class MarkdownDocument
  def initialize(section, filename)
    @section = section
    @file_name = filename
  end

  def parse
    return unless File.file?(file_path)

    @parsed = FrontMatterParser::Parser.new(:md).call(file_content)
    @kramdown_document = Kramdown::Document.new(@parsed.content)
    self
  end

  def title
    @parsed.front_matter["title"]
  end

  def category_tags
    @parsed.front_matter["category_tags"]&.split(",")&.map(&:strip)
  end

  def date_posted
    @parsed.front_matter["date_posted"]
  end

  def meta_description
    @parsed.front_matter["meta_description"]
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

  private

  def file_content
    binding.pry
    File.read(file_path)
  end

  def file_path
    Rails.root.join("app", "views", "content", @section, "#{@file_name}.md")
  end
end
