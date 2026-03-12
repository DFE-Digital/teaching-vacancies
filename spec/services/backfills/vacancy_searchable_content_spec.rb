require "rails_helper"

RSpec.describe Backfills::VacancySearchableContent do
  describe ".call" do
    context "when there are vacancies without searchable_content" do
      let!(:vacancy) { create(:vacancy) }
      let!(:another_vacancy) { create(:vacancy) }

      before do
        vacancy.update_column(:searchable_content, nil)
        another_vacancy.update_column(:searchable_content, nil)
      end

      it "populates searchable_content for vacancies missing it" do
        expect { described_class.call }.to change { vacancy.reload.searchable_content }.from(nil)
                                       .and change { another_vacancy.reload.searchable_content }.from(nil)
      end
    end

    context "when a vacancy already has searchable_content" do
      let!(:vacancy) { create(:vacancy) }

      it "does not change it" do
        expect { described_class.call }.not_to(change { vacancy.reload.searchable_content })
      end
    end
  end
end
