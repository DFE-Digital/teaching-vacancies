class UpdatesController < ApplicationController
  def show
    update_paths = Dir.glob(Rails.root.join('app/views/updates/update_files/*').to_s)
    @updates = update_file_paths_to_hash(update_paths).sort.reverse.to_h
  end

  def update_file_paths_to_hash(update_paths)
    updates_by_date = {}
    update_paths.each do |update_path|
        path, name, date_array = process_update_path(update_path)
        date = Date.new(*date_array) unless date_array.all?(0)
        (updates_by_date[date] ||= []).push({ path: path, name: name }) if date.present? && name.present?
      rescue ArgumentError
    end
    updates_by_date
  end

  private

  def process_update_path(update_path)
    path = update_path.split('/').last.split('.html').first[1..-1]
    name = update_path.split('/').last.split('.html').first.split('_')[1..-4].join(' ').humanize
    date_array = update_path.split('/').last.split('.html').first.split('_').last(3).map(&:to_i)
    return path, name, date_array
  end
end
