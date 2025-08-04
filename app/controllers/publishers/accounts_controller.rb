class Publishers::AccountsController < ApplicationController
  before_action :require_publisher

  # Confirmation page for unsubscribing from expired vacancy feedback prompt emails
  def confirm_unsubscribe; end

  # Unsubscribe from expired vacancy feedback prompt emails
  def unsubscribe
    publisher.update!(unsubscribed_from_expired_vacancy_prompt_at: Time.current)
  end

  # Confirmation page for opting out of email communications
  def confirm_email_opt_out; end

  # Opt out from email communications
  def email_opt_out
    publisher.update!(email_opt_out: true)
  end

  private

  def publisher
    @publisher ||= Publisher.find_signed(params[:publisher_id])
  end

  def require_publisher
    not_found unless publisher
  end
end
