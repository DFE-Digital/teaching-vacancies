class SharesController < ApplicationController
  def new
    request_event.trigger(:vacancy_share, channel: params[:channel], vacancy_id: vacancy.id)

    redirect_to(redirect_url)
  end

  private

  def redirect_url
    case params[:channel]
    when "facebook"
      "https://www.facebook.com/sharer/sharer.php?u=#{CGI.escape(vacancy.share_url)}"
    when "twitter"
      "https://twitter.com/share?url=#{CGI.escape(vacancy.share_url)}&text=#{CGI.escape(vacancy.job_title_and_parent_organisation_name)}"
    end
  end

  def vacancy
    @vacancy ||= VacancyPresenter.new(Vacancy.find(params[:vacancy_id]))
  end
end
