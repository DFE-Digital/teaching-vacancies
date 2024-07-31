class MarkdownDocument
  include Comparable

  attr_reader :section, :subcategory, :post_name

  def initialize(section:, post_name:, subcategory: nil)
    @section = section
    @post_name = post_name
    @subcategory = subcategory
    parse if exist?
  end

  def self.all(section, subcategory)
    dir_path = Rails.root.join("app", "views", "content", section, subcategory)

    Dir.children(dir_path).map do |file_name|
      new(section: section, post_name: file_name.remove(".md"), subcategory: subcategory)
    end
  end

  def self.all_subcategories(section)
    dir_path = Rails.root.join("app", "views", "content", section, "*.md")
    Dir.glob(dir_path).map do |path|
      file_name = File.basename(path)
      new(section: section, post_name: file_name.remove(".md"))
    end
  end

  def title
    @front_matter["title"]
  end

  def category_tags
    @front_matter["category_tags"]&.split(",")&.map(&:strip)
  end

  def date_posted
    Date.parse(@front_matter["date_posted"]) if @front_matter["date_posted"]
  end

  def meta_description
    @front_matter["meta_description"]
  end

  def card_image
    @front_matter["card-image"]
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

  def order
    @front_matter["order"] || Float::INFINITY
  end

  def <=>(other)
    [order, title] <=> [other.order, other.title]
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
    subcategory_path = [@section, @subcategory].compact
    Rails.root.join("app", "views", "content", *subcategory_path, "#{@post_name}.md")
  end
end
