require "updates_parser"

class UpdatesController < ApplicationController
  def index
    update_paths = Dir.glob(Rails.root.join("app/views/updates/update_files/*").to_s)
    @updates = UpdatesParser.new(update_paths).call.sort.reverse.to_h
  end
end
