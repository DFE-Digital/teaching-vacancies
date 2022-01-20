class PostsController < ApplicationController
  before_action :redirect_if_document_not_found, only: :show

  helper_method :document

  private

  def redirect_if_document_not_found
    redirect_to not_found_path unless document
  end

  def document
    @document ||= MarkdownDocument.new(params[:section], params[:file_name]).parse
  end
end
