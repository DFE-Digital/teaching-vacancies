class PostsController < ApplicationController
  def index
    return not_found if params[:section] == "transcripts"

    @subcategories = MarkdownDocument.all_subcategories(params[:section])
  end

  def subcategory
    return not_found if params[:section] == "transcripts"

    @posts = MarkdownDocument.all(params[:section], params[:subcategory])
    render :subcategory
  end

  def show
    @post = MarkdownDocument.new(section: params[:section], subcategory: params[:subcategory], post_name: params[:post_name])
    not_found unless @post.exist?
  end

  private

  # :nocov:
  def get_subcategories(section)
    content_dir = Rails.root.join("app", "views", "content", section)
    Dir.children(content_dir)
  end
  # :nocov:

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end
end
