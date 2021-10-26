module WithEnv
  def with_env(environment_variables = {}, &block)
    raise "Missing block" unless block

    ClimateControl.modify(environment_variables, &block)
  end
end
