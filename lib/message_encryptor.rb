class MessageEncryptor
  def initialize(data)
    @data = data
  end

  def encrypt
    data.is_a?(Array) ? encrypt_array : crypt.encrypt_and_sign(data)
  end

  def decrypt
    data.is_a?(Array) ? decrypt_array : crypt.decrypt_and_verify(data)
  end

private

  attr_reader :data

  def crypt
    @crypt ||= ActiveSupport::MessageEncryptor.new secret
  end

  def secret
    salt = Rails.application.secrets.secret_key_base
    len = ActiveSupport::MessageEncryptor.key_len
    @secret ||= ActiveSupport::KeyGenerator.new(salt).generate_key(salt, len)
  end

  def encrypt_array
    data.map { |v| crypt.encrypt_and_sign(v) }
  end

  def decrypt_array
    data.map { |v| crypt.decrypt_and_verify(v) }
  end
end
