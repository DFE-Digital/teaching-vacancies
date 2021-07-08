require "rails_helper"

RSpec.describe Search::Strategies::Experiment do
  subject { described_class.new(control, experiment, search_criteria: search_criteria, use_experiment: use_experiment) }

  let(:control_vacancies) { (1..5).map { |i| instance_double(Vacancy, id: i) } }
  let(:experiment_vacancies) { (3..6).map { |i| instance_double(Vacancy, id: i) } }

  let(:control) { double("Control", class: "FooStrategy", vacancies: control_vacancies, total_count: 66) }
  let(:experiment) { double("Experiment", class: "BarStrategy", vacancies: experiment_vacancies, total_count: 99) }

  let(:search_criteria) { double("Criteria", to_json: "{\"foo\": \"bar\"}") }
  let(:use_experiment) { false }

  describe "#vacancies" do
    it "delegates to the control strategy by default" do
      expect(subject.vacancies).to eq(control.vacancies)
    end

    context "when use_experiment is given" do
      let(:use_experiment) { true }

      it "delegates to the experiment strategy" do
        expect(subject.vacancies).to eq(experiment.vacancies)
      end
    end
  end

  describe "#total_count" do
    it "delegates to the control strategy by default" do
      expect(subject.total_count).to eq(control.total_count)
    end

    context "when use_experiment is given" do
      let(:use_experiment) { true }

      it "delegates to the experiment strategy" do
        expect(subject.total_count).to eq(experiment.total_count)
      end
    end
  end

  it "sends an event with the data" do
    expect { subject }.to have_triggered_event(:search_experiment_performed)
      .with_data(
        control_strategy: "FooStrategy",
        experiment_strategy: "BarStrategy",
        search_criteria: "{\"foo\": \"bar\"}",
        control_result_count: 66,
        experiment_result_count: 99,
        matches: 3,
        mismatches_from_control: 2,
        mismatches_from_experiment: 1,
      )
  end

  context "when the experiment strategy raises an error" do
    let(:error) { RuntimeError.new("Oops lol") }

    before do
      expect(experiment).to receive(:vacancies).and_raise(error)
    end

    it "swallows errors and reports them to Rollbar" do
      expect(Rollbar).to receive(:error).with(error)

      expect { subject }.not_to raise_error
    end
  end
end
