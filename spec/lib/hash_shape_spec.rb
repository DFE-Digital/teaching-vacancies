require "rails_helper"
require "hash_shape"

RSpec.describe HashShape do
  describe ".of" do
    it "replaces scalar leaf values with their class name" do
      expect(described_class.of("foo")).to eq("String")
      expect(described_class.of(42)).to eq("Integer")
      expect(described_class.of(nil)).to eq("NilClass")
    end

    it "preserves the keys of nested hashes" do
      expect(described_class.of({ "uid" => "123", "info" => { "email" => "foo@example.com" } }))
        .to eq({ "uid" => "String", "info" => { "email" => "String" } })
    end

    it "maps each element of an array" do
      expect(described_class.of([{ "id" => 1 }, "foo"])).to eq([{ "id" => "Integer" }, "String"])
    end

    it "handles OmniAuth::AuthHash instances" do
      auth_hash = OmniAuth::AuthHash.new(
        uid: "123",
        extra: { raw_info: { organisation: { id: "org-id" } } },
      )

      expect(described_class.of(auth_hash)).to eq(
        "uid" => "String",
        "extra" => { "raw_info" => { "organisation" => { "id" => "String" } } },
      )
    end
  end
end
