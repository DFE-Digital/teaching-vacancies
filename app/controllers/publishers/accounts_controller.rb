class Publishers::AccountsController < ApplicationController
  helper_method :publisher

  def unsubscribe
    publisher.update(unsubscribed_from_expired_vacancy_prompt_at: Time.zone.now)
  end

  private

  def publisher
    @publisher ||= Publisher.find_signed(params[:publisher_id])
  end
end
