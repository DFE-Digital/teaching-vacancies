class HardDeleteRetentionPolicyJob < RetentionPolicyJob
  def perform
    scopes.each { it.find_each(&:destroy) }
  end

  def threshold
    5.years.ago
  end
end
