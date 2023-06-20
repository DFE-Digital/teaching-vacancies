class ImportFromVacancySourcesJob < ApplicationJob
  SOURCES = [
    VacancySource::Source::Every,
    VacancySource::Source::Fusion,
    VacancySource::Source::MyNewTerm,
    VacancySource::Source::UnitedLearning,
    VacancySource::Source::Ventrus,
  ].freeze

  queue_as :default

  def perform
    return if DisableExpensiveJobs.enabled?

    SOURCES.each { |source_klass| import_from_source(source_klass) }
  end

  private

  def import_from_source(source_klass)
    source_name = source_klass.source_name
    import_start_time = Time.zone.now
    total_count = 0
    errors = {}

    source_klass.new.each do |vacancy|
      total_count += 1

      PaperTrail.request(whodunnit: "Import from external source") do
        if vacancy.save
          log(source_name, "Imported vacancy #{vacancy.id}.")
        else
          failure = create_failed_imported_vacancy(source_name, vacancy)
          errors[failure.external_reference] = failure.import_errors
        end
      end
    end
    report_validation_errors(source_name, total_count, errors)
    mark_removed_vacancies_from_source(source_name, import_start_time)
  end

  def mark_removed_vacancies_from_source(source_name, import_start_time)
    Vacancy.live.where(external_source: source_name, updated_at: (...import_start_time)).find_each do |v|
      log(source_name, "Set vacancy #{v.id} as removed from external system.")
      v.update_attribute(:status, :removed_from_external_system)
    end
  end

  def create_failed_imported_vacancy(source_name, vacancy)
    failed_imported_vacancy = FailedImportedVacancy.find_by(external_reference: vacancy.external_reference)

    if failed_imported_vacancy.present?
      log(source_name, "FailedImportedVacancy for #{vacancy.external_reference} already exists.")
      failed_imported_vacancy
    else
      log(source_name, "Creating FailedImportedVacancy for #{vacancy.external_reference}.")
      FailedImportedVacancy.create(source: source_name,
                                   external_reference: vacancy.external_reference,
                                   import_errors: vacancy.errors.to_json,
                                   vacancy: vacancy)
    end
  end

  def report_validation_errors(source_name, total_count, errors)
    return if errors.none?

    failed_percentage = ((errors.count.to_f / total_count) * 100).round(1)
    Sentry.with_scope do |scope|
      scope.set_tags(source: source_name)
      scope.set_context("Import failure rate", { vacancies_in_feed: total_count,
                                                 failed_vacancies_to_import: errors.count,
                                                 failed_percentage: })
      scope.set_context("Validation errors for each external source reference", errors.to_hash)

      log(source_name, "#{errors.count} out of #{total_count} (#{failed_percentage}%) vacancies failed to import.")
      Sentry.capture_message("#{source_name} source: #{failed_percentage}% of vacancies failed to import",
                             level: :warning,
                             fingerprint: ["{{ tags.source }}"]) # Groups all the sentry messages for each source
    end
  end

  def log(source, message)
    Rails.logger.info("[ImportFromVacancySourcesJob][#{source}] #{message}")
  end
end
