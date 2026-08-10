require "rails_helper"

RSpec.describe "ons:import_all" do
  let(:task_path) { "lib/tasks/data" }

  # rubocop:disable RSpec/NamedSubject
  it "calls the others" do
    # %w[create_composites import_counties import_cities import_regions].each do |task|
    #   allow(Rake::Task["ons:#{task}"]).to receive(:invoke)
    # end
    subject.execute
    # %w[create_composites import_counties import_cities import_regions].each do |task|
    #   expect(Rake::Task["ons:#{task}"]).to have_received(:invoke).at_least(:once)
    # end
  end
  # rubocop:enable RSpec/NamedSubject
end
