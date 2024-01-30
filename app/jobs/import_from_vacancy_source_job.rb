class ImportFromVacancySourceJob < ApplicationJob
  queue_as :low

  def perform(source_klass)
    return if DisableExpensiveJobs.enabled?

    @source_name = source_klass.source_name
    import_from_source(source_klass)
  end

  private

  def import_from_source(source_klass)
    total_count = 0
    source_external_references = []
    errors = {}

    source_klass.new.each do |vacancy|
      total_count += 1
      source_external_references << vacancy.external_reference

      # Avoids unnecessary and expensive DB updates for vacancies that have not changed since they were imported.
      next if vacancy.persisted? && !vacancy.changed?

      PaperTrail.request(whodunnit: "Import from external source") do
        # Only attempt to save if there are no errors coming from the source parsing.
        # If we save a vacancy that had custom errors, they get removed with the saving validation and we will miss
        # valuable error debugging information.
        if vacancy.errors.none? && vacancy.save
          log("Imported vacancy #{vacancy.id}.")
        else
          failure = create_failed_imported_vacancy(vacancy)
          errors[failure.external_reference] = failure.import_errors
        end
      end
    end
    report_validation_errors(total_count, errors)
    mark_removed_vacancies_from_source(source_external_references)
  end

  def mark_removed_vacancies_from_source(source_external_references)
    Vacancy.live
           .where(external_source: @source_name)
           .where.not(external_reference: source_external_references)
           .update_all(status: :removed_from_external_system, updated_at: Time.zone.now)
  end

  def create_failed_imported_vacancy(vacancy)
    failed_imported_vacancy = FailedImportedVacancy.find_by(external_reference: vacancy.external_reference)

    if failed_imported_vacancy.present?
      log("FailedImportedVacancy for #{vacancy.external_reference} already exists.")
      failed_imported_vacancy
    else
      log("Creating FailedImportedVacancy for #{vacancy.external_reference}.")
      FailedImportedVacancy.create(source: @source_name,
                                   external_reference: vacancy.external_reference,
                                   import_errors: vacancy.errors.to_json,
                                   vacancy: vacancy)
    end
  end

  def report_validation_errors(total_count, errors)
    return if errors.none?

    failed_percentage = ((errors.count.to_f / total_count) * 100).round(1)
    Sentry.with_scope do |scope|
      scope.set_tags(source: @source_name)
      scope.set_context("Import failure rate", { vacancies_in_feed: total_count,
                                                 failed_vacancies_to_import: errors.count,
                                                 failed_percentage: })
      scope.set_context("Validation errors for each external source reference", errors.to_hash)

      log("#{errors.count} out of #{total_count} (#{failed_percentage}%) vacancies failed to import.")
      Sentry.capture_message("#{@source_name} source: #{failed_percentage}% of vacancies failed to import",
                             level: :warning,
                             fingerprint: ["{{ tags.source }}"]) # Groups all the sentry messages for each source
    end
  end

  def log(message)
    Rails.logger.info("[ImportFromVacancySourceJob][#{@source_name}] #{message}")
  end
end
