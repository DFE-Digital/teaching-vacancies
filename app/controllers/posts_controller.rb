class PostsController < ApplicationController
  before_action :check_file_exists, only: :show

  def show
    @content = Kramdown::Document.new(parsed.content)
    @title = parsed.front_matter["title"]
  end

  private

  def parsed
    @parsed ||= FrontMatterParser::Parser.new(:md).call(file_content)
  end

  def file_content
    File.read(file_path)
  end

  def file_path
    Rails.root.join("app", "views", "content", params[:section], "#{params[:file_name]}.md")
  end

  def check_file_exists
    redirect_to not_found_path unless File.file?(file_path)
  end
end
