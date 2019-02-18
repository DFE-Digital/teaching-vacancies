class FeatureFlag
  def initialize(type)
    @type = type
  end

  def enabled?
    self.class.const_get(key) == 'true'
  end

  private

  def key
    "FEATURE_#{@type.upcase}"
  end
end