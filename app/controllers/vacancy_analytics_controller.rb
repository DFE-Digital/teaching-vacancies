class VacancyAnalyticsController < ApplicationController
  def show
    analytics = VacancyAnalytics
      .where(vacancy_id: params[:job_id])
      .select("id, view_count, referrer_counts")

    render json: analytics
  end
end