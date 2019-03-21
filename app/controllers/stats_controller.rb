class StatsController < ApplicationController
  def index
    @stats = PublicActivity::Activity.order(:key)
                                     .group(:key).count

    expires_in 60.minutes, public: true
  end
end
