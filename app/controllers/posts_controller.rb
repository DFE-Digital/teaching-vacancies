class PostsController < ApplicationController
  def index
    @posts = MarkdownDocument.all(params[:section])
  end

  def show
    @post = MarkdownDocument.new(params[:section], params[:post_name])
    not_found unless @post.exist?
  end

  private

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end
end
