require "rails_helper"

RSpec.describe RemoveStaleVacanciesJob do
  it "deletes all vacancies without a job title" do
    create_list(:vacancy, 2)
    create_list(:vacancy, 2, job_title: nil)
    expect { described_class.perform_now }.to change(Vacancy, :count).from(4).to(2)
  end
end
