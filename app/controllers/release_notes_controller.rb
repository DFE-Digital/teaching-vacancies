class ReleaseNotesController < ApplicationController
  def index
    render "release_notes/releases/#{params[:date]}"
  end

  def show
    release_note_paths = Dir.glob(Rails.root.join('app/views/release_notes/releases/*').to_s)
    @releases = release_note_paths.map { |path| {
      path: path.split('/').last.split('.').first, date: Date.new(*path.split('/').last.split('_')[0..2].map(&:to_i))
    } }
  end
end
