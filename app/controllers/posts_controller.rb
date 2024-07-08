class PostsController < ApplicationController
  def index; end

  def subcategory
    @posts = MarkdownDocument.all(params[:section], params[:subcategory])
    render :subcategory
  end

  def show
    @post = MarkdownDocument.new(params[:section], params[:subcategory], params[:post_name])
    not_found unless @post.exist?
  end

  private

  def get_subcategories(section)
    content_dir = Rails.root.join("app", "views", "content", section)
    Dir.children(content_dir)
  end

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end
end
