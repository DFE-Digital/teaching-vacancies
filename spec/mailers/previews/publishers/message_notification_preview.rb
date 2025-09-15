class Publishers::MessageNotificationPreview < ActionMailer::Preview
  def messages_received_single
    publisher = Publisher.new(email: "publisher@example.com", given_name: "Sarah")
    Publishers::MessageNotificationMailer.messages_received(publisher: publisher, message_count: 1)
  end

  def messages_received_multiple
    publisher = Publisher.new(email: "publisher@example.com", given_name: "Sarah")
    Publishers::MessageNotificationMailer.messages_received(publisher: publisher, message_count: 5)
  end
end