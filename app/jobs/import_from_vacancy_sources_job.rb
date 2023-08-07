class ImportFromVacancySourcesJob < ApplicationJob
  SOURCES = [
    VacancySource::Source::UnitedLearning,
    VacancySource::Source::Fusion,
    VacancySource::Source::MyNewTerm,
    VacancySource::Source::Ventrus,
  ].freeze

  queue_as :default

  def perform
    # return if DisableExpensiveJobs.enabled?

    [VacancySource::Source::Ventrus].each do |source_klass|
      import_start_time = Time.zone.now

      source_klass.new.each do |vacancy|
        PaperTrail.request(whodunnit: "Import from external source") do
          if vacancy.valid?
            import_vacancy(source_klass, vacancy)
          else
            report_validation_errors(source_klass, vacancy)
            create_failed_imported_vacancy(source_klass, vacancy)
          end
        end
      end

      Vacancy.live.where(external_source: source_klass.source_name, updated_at: (...import_start_time)).find_each do |v|
        Rails.logger.info("Set vacancy #{v.id} as removed from external system")
        v.update_attribute(:status, :removed_from_external_system)
      end
    end
  end

  private

  def import_vacancy(source_klass, vacancy)
    vacancy.save
    Rails.logger.info("Imported vacancy #{vacancy.id} from feed #{source_klass.source_name}")
  end

  def create_failed_imported_vacancy(source_klass, vacancy)
    if FailedImportedVacancy.find_by(external_reference: vacancy.external_reference)
      Rails.logger.info("Vacancy #{vacancy.external_reference} failed to save as its a duplicate")
    else
      FailedImportedVacancy.create(source: source_klass.source_name,
                                   external_reference: vacancy.external_reference,
                                   import_errors: vacancy.errors.to_json,
                                   vacancy: vacancy)
    end
  end

  def report_validation_errors(source_klass, vacancy)
    Sentry.with_scope do |scope|
      scope.set_tags(
        source: source_klass.name,
      )
      scope.set_context(
        "Validation errors",
        vacancy.errors.to_hash,
      )
      scope.set_context(
        "Vacancy data",
        vacancy.attributes,
      )

      Sentry.capture_message("Vacancy failed to import", level: :warning)
    end
  end
end
