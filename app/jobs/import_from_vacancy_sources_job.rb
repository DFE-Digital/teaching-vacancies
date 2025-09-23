class ImportFromVacancySourcesJob < ApplicationJob
  SOURCES = [
    Vacancies::Import::Sources::Broadbean,
    # Vacancies::Import::Sources::Every, Temporally disabled as their service is down
    Vacancies::Import::Sources::Fusion,
    Vacancies::Import::Sources::VacancyPoster,
    Vacancies::Import::Sources::Ventrus,
  ].freeze

  queue_as :default

  def perform
    return if DisableIntegrations.enabled?

    SOURCES.each { |source_klass| ImportFromVacancySourceJob.perform_later(source_klass) }
  end
end
