class StatsController < ApplicationController
  def index
    @stats = PublicActivity::Activity.order(:key)
                                     .group(:key).count

    @stats["job_alert.sent"] = AlertRun.sent.count

    expires_in 60.minutes, public: true
  end
end
