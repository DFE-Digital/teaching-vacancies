class UpdatesController < ApplicationController
  def index
    render "updates/update_markdown_files/#{params[:date]}"
  end

  def show
    updates_paths = Dir.glob(Rails.root.join('app/views/updates/update_markdown_files/*').to_s)
    @updates = updates_paths.map { |path| {
      path: path.split('/').last.split('.').first, date: Date.new(*path.split('/').last.split('_')[0..2].map(&:to_i))
    } }
  end
end
