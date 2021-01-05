require "rails_helper"

RSpec.describe UpdatesParser do
  let(:date) { Date.parse("2020-04-10") }
  let(:update_paths) do
    [
      "path/noHtmlOrDateFile",
      "path/no_leading_underscore_or_date.html.erb",
      "path/_update_title_no_date.html.erb",
      "path/_update_title_2020_400_100.html.erb",
      "path/_2020_400_100.html.erb",
      "path/_2020_04_10.html.erb",
      "path/_valid_update_title_2020_04_10.html.erb",
    ]
  end

  describe "#call" do
    it "only adds valid update files to the hash" do
      expect(UpdatesParser.new(update_paths).call[date])
        .to eq([{ path: "valid_update_title_2020_04_10", name: "Valid update title" }])
    end
  end
end
