module Publishers
  module AtsApi
    class CreateVacancyService
      extend OrganisationFetcher

      class << self
        def call(params)
          vacancy = PublishedVacancy.new(sanitised_params(params))

          if vacancy.valid?
            vacancy.save!
            success_response(vacancy)
          elsif (conflict = vacancy.find_conflicting_vacancy)
            track_conflict_attempt(vacancy, conflict)
            conflict_response(conflict, vacancy.errors[:base].first || vacancy.errors[:external_reference].first)
          else
            validation_error_response(vacancy)
          end
        end

        private

        def track_conflict_attempt(vacancy, conflicting_vacancy)
          conflict_type = if vacancy.find_external_reference_conflict_vacancy == conflicting_vacancy
                            "external_reference"
                          else
                            "duplicate_content"
                          end

          fail_safe do
            VacancyConflictAttempt.track_attempt!(
              publisher_ats_api_client: vacancy.publisher_ats_api_client,
              conflicting_vacancy: conflicting_vacancy,
              conflict_type: conflict_type,
            )
          end
        end

        def sanitised_params(params)
          organisations = fetch_organisations(params[:schools])

          params[:publish_on] ||= Time.zone.today.to_s
          params[:is_job_share] = params[:is_job_share].in?([true, "true"])
          params[:visa_sponsorship_available] = params[:visa_sponsorship_available].in?([true, "true"])
          params[:ect_status] = params[:ect_suitable].in?([true, "true"]) ? "ect_suitable" : "ect_unsuitable"
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
            { starts_on: parsed_date.date, start_date_type: parsed_date.type }
          else
            { other_start_date_details: parsed_date.date, start_date_type: parsed_date.type }
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

        def success_response(vacancy)
          { status: :created, json: { id: vacancy.id } }
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
