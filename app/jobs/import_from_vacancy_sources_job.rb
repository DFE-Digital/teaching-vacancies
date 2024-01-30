class ImportFromVacancySourcesJob < ApplicationJob
  SOURCES = [
    VacancySource::Source::Ark,
    VacancySource::Source::Broadbean,
    VacancySource::Source::Every,
    VacancySource::Source::Fusion,
    VacancySource::Source::MyNewTerm,
    VacancySource::Source::UnitedLearning,
    VacancySource::Source::Ventrus,
  ].freeze

  queue_as :default

  def perform
    return if DisableExpensiveJobs.enabled?

    SOURCES.each { |source_klass| ImportFromVacancySourceJob.perform_later(source_klass) }
  end
end
