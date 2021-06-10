require "rails_helper"

RSpec.describe RemoveStaleVacanciesJob do
  it "deletes all vacancies without a job title" do
    2.times { create(:vacancy) }
    2.times { create(:vacancy, job_title: nil) }
    expect { described_class.perform_now }.to change { Vacancy.count }.from(4).to(2)
  end
end
