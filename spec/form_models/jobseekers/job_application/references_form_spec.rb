# frozen_string_literal: true

require "rails_helper"

RSpec.describe Jobseekers::JobApplication::ReferencesForm do
  let(:form) { described_class.new(references_section_completed: true) }

  it "validates the references field" do
    expect(form).not_to be_valid
    expect(form.errors.messages).to eq(references: ["You must provide a minimum of 2 references"])
  end
end
