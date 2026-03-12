require "rails_helper"

RSpec.describe Backfills::VacancyGeolocation do
  describe ".call" do
    context "when there are vacancies without geolocation" do
      let!(:vacancy) { create(:vacancy) }
      let!(:another_vacancy) { create(:vacancy) }

      before do
        vacancy.update_column(:geolocation, nil)
        another_vacancy.update_column(:geolocation, nil)
      end

      it "populates geolocation for vacancies missing it" do
        expect { described_class.call }.to change { vacancy.reload.geolocation }.from(nil)
                                       .and change { another_vacancy.reload.geolocation }.from(nil)
      end
    end

    context "when a vacancy already has a geolocation" do
      let!(:vacancy) { create(:vacancy) }

      it "does not modify it" do
        expect { described_class.call }.not_to(change { vacancy.reload.geolocation })
      end
    end
  end
end
