class SoftDeleteRetentionPolicyJob < RetentionPolicyJob
  def perform
    scopes.each { it.find_each(&:discard!) }
  end

  def threshold
    6.months.ago
  end
end
