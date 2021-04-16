class SharesController < ApplicationController
  def new
    request_event.trigger(:vacancy_share, channel: params[:channel], vacancy_id: vacancy.id)

    redirect_to(redirect_url)
  end

  private

  def redirect_url
    case params[:channel]
    when "facebook"
      "https://www.facebook.com/sharer/sharer.php?u=#{vacancy_share_url}"
    when "twitter"
      "https://twitter.com/share?url=#{vacancy_share_url}&text=#{twitter_text}"
    end
  end

  def vacancy
    @vacancy ||= Vacancy.find(params[:vacancy_id])
  end

  def vacancy_share_url
    CGI.escape(job_url(vacancy))
  end

  def twitter_text
    CGI.escape(t(".job_at", title: vacancy.job_title, organisation: vacancy.parent_organisation_name))
  end
end
