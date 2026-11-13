require "rails_helper"

# The columns are covered by candidates_table_component_spec.rb
RSpec.describe SelectableCandidatesTableComponent, type: :component do
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:status) { :status_submitted }
  let(:alice) { build_stubbed(:job_application, status, first_name: "Alice", last_name: "Archer", vacancy:).decorate }

  # Assertions use `page`: Capybara can't find fields by label in what render_inline returns.
  # The block runs in the view, so it is handed what it needs from the spec.
  before do
    render_in_view_context(described_class, vacancy, [alice]) do |component_class, vacancy, candidates|
      form_with(model: Publishers::JobApplication::TagForm.new, url: "#") do |form|
        render component_class.new(tab_name: "submitted", form_builder: form, vacancy:, candidates:)
      end
    end
  end

  it "has a labelled checkbox for each candidate" do
    expect(page).to have_field("Select Alice Archer", type: :checkbox)
  end

  # Publishers select unsuccessful candidates to send them rejection emails
  context "with an unsuccessful candidate" do
    let(:status) { :status_unsuccessful }

    it "can be selected" do
      expect(page).to have_field("Select Alice Archer", type: :checkbox)
    end
  end

  # The absence is checked alongside the row, so it can't pass just because nothing rendered
  context "with a withdrawn candidate" do
    let(:status) { :status_withdrawn }

    it "cannot be selected" do
      expect(page).to have_table(with_rows: [{ "Name" => "Alice Archer" }])
      expect(page).to have_no_field(type: :checkbox)
    end
  end

  # "Select all" is added by JavaScript, which component specs don't run, so check the markup it needs
  it "has the markup the select-all JavaScript needs" do
    expect(page).to have_css("table[data-controller='multi-select'][data-id-prefix='id_all_submitted-']")
    expect(page).to have_css("th#id_all_submitted-select-all", exact_text: "")
  end
end
