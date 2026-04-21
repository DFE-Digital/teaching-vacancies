require "rails_helper"

RSpec.describe "vacancies:fix_my_new_term_expires_at" do
  include_context "rake"

  let(:task_path) { "lib/tasks/fix_my_new_term_expires_at" }

  # rubocop:disable RSpec/NamedSubject
  it "calls the service" do
    allow(FixMyNewTermExpiresAt).to receive(:call).and_return(1)

    subject.execute

    expect(FixMyNewTermExpiresAt).to have_received(:call)
  end

  it "prints the number of fixed vacancies" do
    allow(FixMyNewTermExpiresAt).to receive(:call).and_return(2)

    expect { subject.execute }.to output("Done. Fixed 2 vacancies.\n").to_stdout
  end
  # rubocop:enable RSpec/NamedSubject
end
