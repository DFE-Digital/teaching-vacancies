class Search::Strategies::Experiment
  def initialize(control, experiment, search_criteria:, use_experiment: false)
    @control = control
    @experiment = experiment

    @search_criteria = search_criteria
    @use_experiment = use_experiment

    compare_and_send_results
  end

  def vacancies
    @vacancies ||= result_strategy.vacancies
  end

  def total_count
    @total_count ||= result_strategy.total_count
  end

  private

  attr_reader :control, :experiment, :search_criteria, :use_experiment

  def result_strategy
    use_experiment ? experiment : control
  end

  def compare_and_send_results
    control_ids = control.vacancies.map(&:id)
    experiment_ids = experiment.vacancies.map(&:id)

    Event.new.trigger(
      :search_experiment_performed,
      control_strategy: control.class.to_s,
      experiment_strategy: experiment.class.to_s,
      search_criteria: search_criteria.to_json,
      control_result_count: control.total_count,
      experiment_result_count: experiment.total_count,
      matches: (control_ids & experiment_ids).count,
      mismatches_from_control: (control_ids - experiment_ids).count,
      mismatches_from_experiment: (experiment_ids - control_ids).count,
    )
  rescue StandardError => e
    Rollbar.error(e)
  end
end
