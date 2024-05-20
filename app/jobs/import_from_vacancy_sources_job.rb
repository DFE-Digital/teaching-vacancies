class ImportFromVacancySourcesJob < ApplicationJob
  SOURCES = [
    Vacancies::Import::Sources::Ark,
    Vacancies::Import::Sources::Broadbean,
    Vacancies::Import::Sources::Every,
    Vacancies::Import::Sources::Fusion,
    Vacancies::Import::Sources::MyNewTerm,
    Vacancies::Import::Sources::UnitedLearning,
    Vacancies::Import::Sources::VacancyPoster,
    Vacancies::Import::Sources::Ventrus,
  ].freeze

  queue_as :default

  def perform
    return if DisableExpensiveJobs.enabled?

    SOURCES.each { |source_klass| ImportFromVacancySourceJob.perform_later(source_klass) }
  end
end
