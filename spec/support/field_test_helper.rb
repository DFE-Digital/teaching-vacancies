module FieldTestHelper
  # Force a specific experiment alternative to always be returned:
  def use_ab_test(participant, experiment, variant)
    experiment = FieldTest::Experiment.find(experiment)
    experiment.variant(participant, variant: variant.to_s)
  end
end
