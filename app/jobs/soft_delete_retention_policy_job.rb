class SoftDeleteRetentionPolicyJob < RetentionPolicyJob
  # soft deletion relies on `Discard::Model` being included in model

  def perform
    scopes.each { it.find_each(&:discard!) }
  end

  def threshold
    6.months.ago
  end
end
