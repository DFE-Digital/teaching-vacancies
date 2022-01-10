class UpdatesParser
  def initialize(update_paths)
    @update_paths = update_paths
  end

  def call
    update_file_paths_to_hash(@update_paths)
  end

  private

  def update_file_paths_to_hash(update_paths)
    updates_by_date = {}
    update_paths.each do |update_path|
      path, name, date_array = process_update_path(update_path)
      date = Date.new(*date_array) unless date_array.all?(0)
      (updates_by_date[date] ||= []).push({ path:, name: }) if date.present? && name.present?
    rescue ArgumentError
      "DO NOTHING"
    end
    updates_by_date
  end

  def process_update_path(update_path)
    path = update_path.split("/").last.split(".html").first[1..]
    name = update_path.split("/").last.split(".html").first.split("_")[1..-4].join(" ").humanize
    date_array = update_path.split("/").last.split(".html").first.split("_").last(3).map(&:to_i)
    [path, name, date_array]
  end
end
