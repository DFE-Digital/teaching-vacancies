class Counter
  attr_reader :model

  class << self
    attr_reader :persisted_column, :redis_counter_name
  end

  def track
    redis_counter.increment
  end

  def persist!
    return if redis_counter.to_i.zero?

    model.send("#{self.class.persisted_column}=", increment_persisted_counter)
    model.send("#{persisted_at_column}=", Time.current)
    reset_counter if model.save
  end

private

  def increment_persisted_counter
    model.send(self.class.persisted_column).to_i + redis_counter.to_i
  end

  def redis_counter
    @redis_counter ||= model.send(self.class.redis_counter_name)
  end

  def reset_counter
    redis_counter.reset
  end

  def persisted_at_column
    "#{self.class.persisted_column}_updated_at".to_sym
  end
end
