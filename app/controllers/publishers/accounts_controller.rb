class Publishers::AccountsController < ApplicationController
  before_action :set_publisher

  def unsubscribe
    @publisher.update(unsubscribed_from_expired_vacancy_prompt_at: Time.zone.now)
  end

  private

  def set_publisher
    @publisher = Publisher.find_signed(params[:publisher_id])
  end
end
