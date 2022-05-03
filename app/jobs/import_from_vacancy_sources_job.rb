class ImportFromVacancySourcesJob < ApplicationJob
  SOURCES = [UnitedLearningVacancySource].freeze

  queue_as :default

  def perform
    return if DisableExpensiveJobs.enabled?

    SOURCES.each do |source_klass|
      import_start_time = Time.zone.now

      source_klass.new.each do |vacancy|
        PaperTrail.request(whodunnit: "Import from external source") do
          if vacancy.save
            Rails.logger.info("Imported vacancy #{vacancy.id} from feed #{source_klass.source_name}")
          else
            report_validation_errors(source_klass, vacancy)
            Rails.logger.error("Failed to save imported vacancy: #{vacancy.errors.inspect}")
          end
        end
      end

      Vacancy.live.where(external_source: source_klass.source_name, updated_at: (...import_start_time)).find_each do |v|
        Rails.logger.info("Set vacancy #{v.id} as removed from external system")
        v.update(status: :removed_from_external_system)
      end
    end
  end

  private

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

      Sentry.capture_message("Vacancy failed to import")
    end
  end
end
