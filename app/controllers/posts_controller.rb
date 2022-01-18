class PostsController < ApplicationController
  def show
    @content = Kramdown::Document.new(parsed.content).to_html
    @title = parsed.front_matter["title"]
  end

  private

  def parsed
    FrontMatterParser::Parser.new(:md).call(file_content)
  end

  def file_content
    File.read(Rails.root.join("app", "views", "content", section, file_name))
  end

  def section
    request.path.split("/").second
  end

  def file_name
    "#{params[:id]}.md"
  end
end
