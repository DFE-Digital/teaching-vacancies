module WithEnv
  def with_env(environment_variables = {}, &block)
    raise "Missing block" unless block_given?

    ClimateControl.modify(environment_variables, &block)
  end
end
