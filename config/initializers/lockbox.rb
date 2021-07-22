module Lockbox
  class Encryptor
    # Wrap original `decrypt` method with error handling so that we can display 'Lorem ipsum'
    # for encrypted data in the staging environment while using a production data dump.

    # Using this StackOverflow way in order to avoid duplicating the method implementation
    # https://stackoverflow.com/a/4471202

    old_decrypt = instance_method(:decrypt)

    define_method(:decrypt) do |ciphertext, **options|
      old_decrypt.bind_call(self, ciphertext, **options)
    rescue DecryptionError
      return "Lorem ipsum"
    end
  end
end
