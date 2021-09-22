module LogBenchmark
  def log_benchmark(label)
    start_time = Time.now.to_i

    Rails.logger.tagged(self.class.name) do
      Rails.logger.info("Started #{label}")
      yield
      Rails.logger.info("Finished #{label} (#{Time.now.to_i - start_time}s elapsed)")
    end
  end
end
