class StatsController < ApplicationController
  def index
    @audit_summary = PublicActivity::Activity.order(:key)
                                             .group(:key).count

    expires_in 60.minutes, public: true
  end
end
