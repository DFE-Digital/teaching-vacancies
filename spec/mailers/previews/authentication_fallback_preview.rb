# Preview all emails at http://localhost:3000/rails/mailers
class AuthenticationFallbackPreview < ActionMailer::Preview
  def sign_in_fallback
    unless Publisher.any?
      raise "I don't want to mess up your development database with factory-created records, so this preview won't
            run unless there is >=1 publisher in the database."
    end

    AuthenticationFallbackMailer.sign_in_fallback(login_key_id: "example", publisher: Publisher.first)
  end
end
