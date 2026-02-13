class EmailAddressValidator < ValidEmail2::EmailValidator
  def default_options
    super.merge(strict_mx: Rails.application.config.strict_mx_validation)
  end
end
