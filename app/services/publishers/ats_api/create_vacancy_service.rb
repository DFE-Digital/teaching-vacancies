module Publishers
  module AtsApi
    class CreateVacancyService
      extend OrganisationFetcher

      class << self
        def call(params)
          vacancy = Vacancy.new(sanitised_params(params))

          if (conflict = find_conflicting_vacancy(vacancy))
            return conflict_response(conflict[:vacancy], conflict[:error_message])
          end

          vacancy.save ? success_response(vacancy) : validation_error_response(vacancy)
        end

        private

        def sanitised_params(params)
          organisations = fetch_organisations(params[:schools])

          params[:publish_on] ||= Time.zone.today.to_s
          params.except(:schools).merge(organisations: organisations)
        end

        def find_conflicting_vacancy(vacancy)
          if (conflict = conflict_vacancy(vacancy))
            { vacancy: conflict, error_message: "A vacancy with the provided ATS client ID and external reference already exists." }
          elsif (duplicate = duplicate_vacancy(vacancy))
            { vacancy: duplicate, error_message: "A vacancy with the same job title, expiry date, and organisation already exists." }
          end
        end

        def conflict_vacancy(vacancy)
          Vacancy.find_by(
            publisher_ats_api_client_id: vacancy.publisher_ats_api_client_id,
            external_reference: vacancy.external_reference,
          )
        end

        def duplicate_vacancy(vacancy)
          Vacancy.joins(:organisations).where(
            job_title: vacancy.job_title,
            expires_at: vacancy.expires_at,
            organisations: { id: vacancy.organisation_ids },
          ).distinct.first
        end

        def conflict_response(conflict_vacancy, error_message)
          {
            status: :conflict,
            json: {
              error: error_message,
              link: Rails.application.routes.url_helpers.vacancy_url(conflict_vacancy),
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
