# Documentation: app/mailers/previewing_emails.md
class Publishers::AuthenticationFallbackPreview < ActionMailer::Preview
  def sign_in_fallback
    unless Publisher.any?
      raise "I don't want to mess up your development database with factory-created records, so this preview won't
            run unless there is >=1 publisher in the database."
    end

    Publishers::AuthenticationFallbackMailer.sign_in_fallback(login_key_id: "example", publisher: Publisher.first)
  end
end
