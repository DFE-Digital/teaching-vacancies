class MarkdownDocument
  def initialize(section, filename)
    @section = section
    @file_name = filename
  end

  def parse
    return unless File.file?(file_path)

    @parsed = FrontMatterParser::Parser.new(:md).call(file_content)
    binding.pry
    @kramdown_document = Kramdown::Document.new(@parsed.content)
    self
  end

  def title
    @parsed.front_matter["title"]
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
    File.read(file_path)
  end

  def file_path
    Rails.root.join("app", "views", "content", @section, "#{@file_name}.md")
  end
end
