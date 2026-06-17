class ApplicationQuery
  # Delegate class-level call to a new instance - allows using class name as an argument
  # to scope declaration, e.g:
  #   scope :foo, FooQuery
  def self.call(...)
    new.call(...)
  end
end
