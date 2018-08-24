class StatsController < ApplicationController
  def index
    @audit_summary = PublicActivity::Activity.order(:key)
                                             .group(:key).count
  end
end
