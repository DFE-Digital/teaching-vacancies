module Publishers
  module AtsApi
    class UpdateVacancyService
      extend OrganisationFetcher

      class << self
        def call(vacancy, params)
          vacancy.assign_attributes(sanitised_params(params))

          if vacancy.valid?
            vacancy.refresh_slug
            vacancy.save!
            { status: :ok }
          elsif (conflict = vacancy.find_conflicting_vacancy)
            track_conflict_attempt(vacancy, conflict)
            conflict_response(conflict, vacancy.errors[:base].first || vacancy.errors[:external_reference].first)
          else
            validation_error_response(vacancy)
          end
        end

        private

        def track_conflict_attempt(vacancy, conflicting_vacancy)
          return unless vacancy.publisher_ats_api_client.present?

          conflict_type = if vacancy.find_external_reference_conflict_vacancy == conflicting_vacancy
                            "external_reference"
                          else
                            "duplicate_content"
                          end

          VacancyConflictAttempt.track_attempt!(
            publisher_ats_api_client: vacancy.publisher_ats_api_client,
            conflicting_vacancy: conflicting_vacancy,
            conflict_type: conflict_type,
          )
        rescue StandardError => e
          Rails.logger.error("Failed to track conflict attempt: #{e.message}")
        end

        def sanitised_params(params)
          organisations = fetch_organisations(params[:schools])
          ect_status = ect_status_from(params[:ect_suitable])
          params[:ect_status] = ect_status if ect_status.present?
          params.except(:schools, :ect_suitable)
                .merge(organisations: organisations)
                .merge(start_date_fields(params[:starts_on]))
        end

        def start_date_fields(starts_on)
          return {} if starts_on.blank?

          # Reusing this date parser from the legacy importers.
          # We will need to move this class to AtsApi module when removing the legacy codebase.
          parsed_date = ::Vacancies::Import::Parser::StartDate.new(starts_on)
          if parsed_date.specific?
            { starts_on: parsed_date.date, start_date_type: parsed_date.type, other_start_date_details: nil }
          else
            { other_start_date_details: parsed_date.date, start_date_type: parsed_date.type, starts_on: nil }
          end
        end

        # On the update, does not change the already set value unless it is explicitly set to true/false.
        def ect_status_from(ect_suitable)
          case ect_suitable
          when true, "true" then "ect_suitable"
          when false, "false" then "ect_unsuitable"
          end
        end

        def conflict_response(conflict_vacancy, error_message)
          {
            status: :conflict,
            json: {
              errors: [error_message],
              meta: {
                link: Rails.application.routes.url_helpers.vacancy_url(conflict_vacancy.id),
              },
            },
          }
        end

        def validation_error_response(vacancy)
          {
            status: :unprocessable_entity,
            json: {
              errors: vacancy.errors.messages.flat_map do |attr, messages|
                messages.map { |message| "#{attr}: #{message}" }
              end,
            },
          }
        end
      end
    end
  end
end
