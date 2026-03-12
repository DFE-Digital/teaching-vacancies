# frozen_string_literal: true

require "rails_helper"

RSpec.describe VacancyTemplate do
  describe "columns" do
    it "has similar columns to vacancy" do
      pending("no idea which columns yet")
      expect(Vacancy.columns.map(&:name) - described_class.columns.map(&:name)).to eq([])
    end
  end
end
