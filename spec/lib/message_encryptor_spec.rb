require "rails_helper"
require "message_encryptor"

RSpec.describe MessageEncryptor do
  describe "it can #encrypt and #decrypt data" do
    it "an array" do
      data = %w[an array of data]
      encrypted_data = MessageEncryptor.new(data).encrypt

      expect(MessageEncryptor.new(encrypted_data).decrypt).to eq(data)
    end

    it "a string" do
      data = "The quick brown fox"
      encrypted_data = MessageEncryptor.new(data).encrypt

      expect(MessageEncryptor.new(encrypted_data).decrypt).to eq(data)
    end
  end
end
