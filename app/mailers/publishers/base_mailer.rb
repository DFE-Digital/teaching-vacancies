class Publishers::BaseMailer < ApplicationMailer
  private

  def email_event
    @email_event ||= EmailEvent.new(@template, @to, publisher: @publisher)
  end

  def email_event_prefix
    "publisher"
  end
end
