require "rails_helper"
RSpec.describe "rake vacancies:statistics:refresh_cache", type: :task do
  it "Queues jobs to update cached information on active and not expired vacancies" do
    active_vacancies = create_list(:vacancy, 10, :published)
    draft_vacancies = create_list(:vacancy, 5, :draft)
    expired_vacancies = build_list(:vacancy, 5, :expired).each { |v| v.save(validate: false) }

    active_vacancies.each do |vacancy|
      expect(PersistVacancyPageViewJob).to receive(:perform_later).with(vacancy.id)
      expect(PersistVacancyGetMoreInfoClickJob).to receive(:perform_later).with(vacancy.id)
    end

    draft_vacancies.each do |vacancy|
      expect(PersistVacancyPageViewJob).to_not receive(:perform_later).with(vacancy.id)
      expect(PersistVacancyGetMoreInfoClickJob).to_not receive(:perform_later).with(vacancy.id)
    end

    expired_vacancies.each do |vacancy|
      expect(PersistVacancyPageViewJob).to_not receive(:perform_later).with(vacancy.id)
      expect(PersistVacancyGetMoreInfoClickJob).to_not receive(:perform_later).with(vacancy.id)
    end

    task.invoke
  end
end
