class PostsController < ApplicationController
  before_action :redirect_if_post_not_found, only: :show

  helper_method :post

  private

  def redirect_if_post_not_found
    not_found unless post.exist?
  end

  def post
    @post ||= MarkdownDocument.new(params[:section], params[:post_name])
  end
end
