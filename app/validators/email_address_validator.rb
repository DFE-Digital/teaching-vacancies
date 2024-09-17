class EmailAddressValidator < ValidEmail2::EmailValidator
  def default_options
    super.merge(strict_mx: true)
  end
end
