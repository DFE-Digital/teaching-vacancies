class Publishers::AccountsController < ApplicationController
  helper_method :publisher

  # Unsubscribe from expired vacancy feedback prompt emails
  def unsubscribe
    publisher.update(unsubscribed_from_expired_vacancy_prompt_at: Time.current)
  end

  # Confirmation page for opting out of email communications
  def confirm_email_opt_out
    not_found unless publisher
  end

  # Opt out from email communications
  def email_opt_out
    return not_found unless publisher

    publisher.update!(email_opt_out: true)
  end

  private

  def publisher
    @publisher ||= Publisher.find_signed(params[:publisher_id])
  end
end
