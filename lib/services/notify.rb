require 'notifications/client'

class Notify
  def initialize(email, personalisation, template_id, reference)
    @email = email
    @template_id = template_id
    @reference = reference
    @personalisation = personalisation
  end

  def call
    raise 'Notify: NOTIFY_KEY is not set' if NOTIFY_KEY.blank?

    send_email
  end

  private

  attr_reader :email, :template_id, :reference, :personalisation

  def client
    @client ||= Notifications::Client.new(NOTIFY_KEY)
  end

  def email_params
    {
      email_address: email,
      template_id: template_id,
      personalisation: personalisation,
      reference: reference
    }
  end

  def send_email
    client.send_email(email_params)
  end
end
