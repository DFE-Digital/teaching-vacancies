class AutoExpireCacheRedis
  def initialize(store, ttl)
    @store = store
    @ttl = ttl
  end

  def [](url)
    @store.get(url)
  end

  def []=(url, value)
    @store.set(url, value)
    @store.expire(url, @ttl)
  end

  def keys
    @store.keys
  end

  def del(url)
    @store.del(url)
  end
end
