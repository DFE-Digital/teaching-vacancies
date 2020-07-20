class Flag
  def initialize(name, is_feature: true)
    @name = name.upcase
    @is_feature = is_feature
  end

  def enabled?
    self.class.const_get(key) == 'true'
  end

  private

  attr_accessor :is_feature

  def key
    is_feature ? "FEATURE_#{@name}" : @name
  end
end
