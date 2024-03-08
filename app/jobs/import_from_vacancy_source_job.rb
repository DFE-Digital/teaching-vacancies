class ImportFromVacancySourceJob < ApplicationJob
  queue_as :low

  def perform(source_klass)
    return if DisableExpensiveJobs.enabled?

    @source_klass = source_klass
    @source_name = source_klass.source_name
    @vacancies_count = 0
    @external_references = []
    @errors = {}

    import_from_source
    report_validation_errors
    mark_removed_vacancies_from_source
  end

  private

  def import_from_source
    @source_klass.new.each do |vacancy|
      @vacancies_count += 1
      @external_references << vacancy.external_reference
      next if existing_vacancy_unchanged?(vacancy)

      PaperTrail.request(whodunnit: "Import from external source") do
        # Only attempt to save if there are no errors coming from the source parsing.
        # If we save a vacancy that had custom errors, they get removed with the saving validation and we will miss
        # valuable error debugging information.
        if vacancy.errors.none? && vacancy.save
          log("Imported vacancy #{vacancy.id}.")
        else
          failure = create_failed_imported_vacancy(vacancy)
          @errors[failure.external_reference] = failure.import_errors
        end
      end
    end
  end

  # Avoids unnecessary and expensive DB updates for vacancies that have not changed since they were imported.
  #
  # Before checking for changes it calls a method that sets to 'nil' multiple invalid field values.
  # This method is called as an AR callback on the vacancy before it is saved.
  # Calling it here avoids 'changed?' returning true when, after being normalised by the callback and saved,
  # the DB value wouldn't change.
  def existing_vacancy_unchanged?(vacancy)
    vacancy.reset_dependent_fields
    vacancy.persisted? && !vacancy.changed?
  end

  def mark_removed_vacancies_from_source
    Vacancy.live
           .where(external_source: @source_name)
           .where.not(external_reference: @external_references)
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

  def report_validation_errors
    failed_percentage = @errors.any? ? ((@errors.count.to_f / @vacancies_count) * 100).round(1) : 0

    Sentry.with_scope do |scope|
      scope.set_tags(source: @source_name)
      scope.set_context("Import failure rate", { vacancies_in_feed: @vacancies_count,
                                                 failed_vacancies_to_import: @errors.count,
                                                 failed_percentage: })
      scope.set_context("Validation errors for each external source reference", @errors.to_hash)

      log("#{@errors.count} out of #{@vacancies_count} (#{failed_percentage}%) vacancies failed to import.")
      Sentry.capture_message("#{@source_name} source: #{failed_percentage}% of vacancies failed to import",
                             level: :warning,
                             fingerprint: ["{{ tags.source }}"]) # Groups all the sentry messages for each source
    end
  end

  def log(message)
    Rails.logger.info("[ImportFromVacancySourceJob][#{@source_name}] #{message}")
  end
end
