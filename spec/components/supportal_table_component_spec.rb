require "rails_helper"

RSpec.describe SupportalTableComponent, type: :component do
  let(:kwargs) do
    {
      entries: entries,
    }
  end

  let(:entries) do
    [
      create(:feedback),
      create(
        :feedback,
        comment: "A comment",
        relevant_to_user: true,
        search_criteria: {
          keyword: "blah",
          radius: "10",
        },
      ),
    ]
  end

  before do
    render_inline(described_class.new(**kwargs)) do |t|
      t.datetime "Timestamp", :created_at
      t.boolean "Relevant?", :relevant_to_user
      t.text "Comment", :comment
      t.tags("Criteria") { |f| (f.search_criteria || {}).keys }
      t.string "Email", :email
      t.column("Generic column") { "generic text" }
    end
  end

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders one column header per column" do
    expect(page).to have_css("th", count: 6)
  end

  it "renders one row per entry" do
    expect(page).to have_css("tbody .govuk-table__row", count: 2)
  end

  it "uses the provided label for the column headers" do
    [
      "Timestamp",
      "Relevant?",
      "Comment",
      "Criteria",
      "Email",
      "Generic column",
    ].each do |label|
      expect(page).to have_css("th", text: label)
    end
  end

  it "applies a CSS class for each column type" do
    %w[
      boolean
      datetime
      string
      tags
      text
    ].each do |type|
      expect(page).to have_css("th.column-width--#{type}", count: 1)
    end

    # Generic columns don't get a special class
    expect(page).not_to have_css("th.column-width--column")
  end

  it "treats symbols as method names for getting values" do
    expect(page).to have_css("tbody .govuk-table__row:last-of-type") do |row|
      expect(row).to have_text("A comment")
    end
  end

  it "treats blocks as procs for getting values" do
    expect(page).to have_css("tbody .govuk-table__row:last-of-type") do |row|
      expect(row).to have_text("generic text")
    end
  end

  it "formats certain column types" do
    expect(page).to have_css("tbody .govuk-table__row:last-of-type") do |row|
      expect(row).to have_text("Yes") # boolean
      expect(row).to have_text("Keyword") # tags
      expect(row).to have_text("Radius") # tags
    end
  end
end
