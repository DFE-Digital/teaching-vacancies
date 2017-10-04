class PublishVacancyForm
  attr_reader :stages

  def initialize(stages)
    @stages = stages
  end

  def default_stage
    @stages.keys.first
  end

  def step(current_stage)
    index = @stages.keys.find_index(current_stage) || 0
    index + 1
  end
end